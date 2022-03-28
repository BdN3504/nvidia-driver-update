#!/bin/bash
source driver-update-variables.sh

dpkg -s curl &> /dev/null
curlInstalled=$?
if [ $curlInstalled -ne 0 ]
then
  apt -yq install curl
fi

dpkg -s pup &> /dev/null
pupInstalled=$?
if [ $pupInstalled -ne 0 ]
then
  apt -yq install pup
fi

dpkg -s jq &> /dev/null
jqInstalled=$?
if [ $jqInstalled -ne 0 ]
then
  apt -yq install ncat
fi

dpkg -s wget &> /dev/null
wgetInstalled=$?
if [ $wgetInstalled -ne 0 ]
then
  apt -yq install wget
fi

latestVersionDirectory=$(curl --silent "$baseUrl" | pup 'ul.directorycontents li span.dir json{}' | jq -r ".[-1].children[0].href")
latestVersionFileName="$fileNamePrefix${latestVersionDirectory::-1}$fileNameSuffix"
latestVersionUrl="$baseUrl$latestVersionDirectory$latestVersionFileName"
if [ ! -f "$latestVersionFileName" ]
then
  wget -O "$latestVersionFileName" "$latestVersionUrl"
fi
stty -echo
printf "Enter signing pin: "
read -r KBUILD_SIGN_PIN
stty echo
printf "\n"
export "KBUILD_SIGN_PIN"
sh ./"$latestDriver" -s --module-signing-secret-key="$privateKeyFilePath" --module-signing-public-key="$publicKeyFilePath"
nvidia-xconfig

if [ $wgetInstalled -ne 0 ]
then
  apt -yq purge wget
fi

if [ $jqInstalled -ne 0 ]
then
  apt -yq purge jq
fi

if [ $pupInstalled -ne 0 ]
then
  apt -yq purge pup
fi

if [ $curlInstalled -ne 0 ]
then
  apt -yq purge curl
fi
