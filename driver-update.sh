#!/bin/bash
cd "$(dirname "$(readlink -f "$0")")" || exit 1
source driver-update-variables.sh

if [ "$(id -u)" -ne 0 ]
then
  echo "Run this script as root." >&2
  exit 1
fi

dpkg -s curl &> /dev/null
curlInstalled=$?
if [ $curlInstalled -ne 0 ]
then
  apt -yq install curl
fi

# dkms rebuilds the module on kernel updates, which needs the headers of every future kernel
apt -yq install dkms "linux-headers-$(dpkg --print-architecture)" || exit 1

# Download and verify the driver before touching the running system
if [ "$driverVersion" == "latest" ] || [ "$driverVersion" == "newest" ]
then
  # The directory listing contains one "<version>/" directory per release
  newestVersion=$(curl --silent --fail "$baseUrl" | grep -oE "href='[0-9]+(\.[0-9]+)+/'" | grep -oE "[0-9]+(\.[0-9]+)+" | sort -V | tail -n 1)
  if [ -z "$newestVersion" ]
  then
    echo "Could not read the driver versions from $baseUrl" >&2
    exit 1
  fi
fi
if [ "$driverVersion" == "latest" ]
then
  # latest.txt contains "<version> <version>/<file name>"
  read -r latestVersion _ < <(curl --silent --fail "${baseUrl}latest.txt")
  if [ -z "$latestVersion" ]
  then
    echo "Could not read ${baseUrl}latest.txt" >&2
    exit 1
  fi
  driverVersion=$latestVersion
  # nvidia's latest.txt points to the recommended release, which can lag behind the newest one
  if [ "$latestVersion" != "$newestVersion" ]
  then
    read -r -p "Install the latest recommended driver $latestVersion or the newest driver $newestVersion? [L/n] " installNewest
    if [[ "$installNewest" == [nN]* ]]
    then
      driverVersion=$newestVersion
    fi
  fi
elif [ "$driverVersion" == "newest" ]
then
  driverVersion=$newestVersion
fi
driverFileName="$fileNamePrefix$driverVersion$fileNameSuffix"
driverUrl="$baseUrl$driverVersion/$driverFileName"
echo "Driver version: $driverVersion"
if [ ! -f "$driverFileName" ]
then
  curl --location --fail --output "$driverFileName" "$driverUrl" || { rm -f "$driverFileName"; exit 1; }
fi
sh ./"$driverFileName" --check || exit 1

if [ $curlInstalled -ne 0 ]
then
  apt -yq purge curl
fi

# The installer refuses to install over a driver from the distribution's packages
distributionPackages=$(dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' | awk '$1 == "ii" && $2 ~ /nvidia|libcuda|libnvcuvid/ { print $2 }')
if [ -n "$distributionPackages" ]
then
  echo "Removing the NVIDIA driver installed from the distribution's packages. Check the list before confirming."
  apt purge $distributionPackages || exit 1
fi

# Purging the distribution's packages also removes their nouveau blacklist
if ! grep -qsE '^\s*blacklist\s+nouveau' /etc/modprobe.d/*.conf
then
  printf "blacklist nouveau\noptions nouveau modeset=0\n" > /etc/modprobe.d/nvidia-installer-disable-nouveau.conf
  update-initramfs -u
fi

if systemctl is-active --quiet display-manager
then
  if [[ "$(tty)" != /dev/tty[0-9]* ]]
  then
    read -r -p "Stopping the display manager ends all graphical sessions, including this terminal if it runs inside one. Continue? [y/N] " stopDisplayManager
    if [[ "$stopDisplayManager" != [yY]* ]]
    then
      echo "Switch to a text console (e.g. Ctrl+Alt+F3) and run this script again."
      exit 1
    fi
  fi
  systemctl stop display-manager
fi

systemctl stop nvidia-persistenced &> /dev/null
for module in nvidia_drm nvidia_modeset nvidia_uvm nvidia_peermem nvidia nouveau
do
  if [ -d "/sys/module/$module" ] && ! rmmod "$module"
  then
    echo "Kernel module $module is still in use. Reboot and run this script again." >&2
    exit 1
  fi
done

installerArguments=(--silent --dkms --kernel-module-type="$kernelModuleType")

if [ "$runNvidiaXconfig" == "yes" ]
then
  installerArguments+=(--run-nvidia-xconfig)
fi

# The last byte of the SecureBoot EFI variable is 1 when secure boot is enabled
secureBootState=$(od -An -t u1 /sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c 2>/dev/null | awk '{ print $NF }')
if [ "$secureBootState" == "1" ]
then
  stty -echo
  printf "Enter signing pin: "
  read -r KBUILD_SIGN_PIN
  stty echo
  printf "\n"
  export "KBUILD_SIGN_PIN"
  installerArguments+=(--module-signing-secret-key="$privateKeyFilePath" --module-signing-public-key="$publicKeyFilePath")
fi

echo "Going to run sh ./$driverFileName ${installerArguments[*]}"
if ! sh ./"$driverFileName" "${installerArguments[@]}"
then
  echo "Installation failed, see /var/log/nvidia-installer.log" >&2
  exit 1
fi

echo "Driver $driverVersion installed. Reboot to start using it."
