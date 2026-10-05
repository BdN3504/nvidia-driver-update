# nvidia driver updater

Installing the nvidia linux driver on a machine that has secure boot enabled [is hard enough](https://askubuntu.com/questions/1023036/how-to-install-nvidia-driver-with-secure-boot-enabled).
Only seeing the terminal after a kernel update after having gone through the hassle of setting
up the driver is mildly infuriating. The easiest solution to have a working desktop environment
is to re-install the driver after the kernel update. It's not so easy if you are only looking
at a terminal though.

To overcome the struggle of manually installing the driver after each kernel update, you can
use this script.

With `--dkms` the kernel module is rebuilt automatically on kernel updates, so the script is
mainly needed to install the driver for the first time and to move to a newer driver version.

## Assumptions
1. You are running debian.
2. If secure boot is enabled, you already have enrolled a key pair to MOK. Without secure boot
   no keys are needed.
3. You are online.

## Usage
### 1. Set up variables
Run `/bin/bash driver-update-variables.sh`. This will interactively set the following variables:

| Variable  | Description  | Default  |
|---|---|---|
| baseUrl  | URL to nvidia's driver directory. Other architectures are listed [here](http://download.nvidia.com/XFree86/). | http://download.nvidia.com/XFree86/Linux-x86_64/  |
| fileNamePrefix  | Prefix of the driver file name. Adjust according to your architecture. | NVIDIA-Linux-x86_64-  |
| fileNameSuffix  |  Suffix of the driver file name. | .run  |
| driverVersion  | Driver version to install, e.g. `580.126.09`. `latest` uses the version from nvidia's `latest.txt`. | latest  |
| kernelModuleType  | `open` for Turing (RTX 20xx / GTX 16xx) and newer GPUs, `proprietary` for older ones. | open  |
| runNvidiaXconfig  | `yes` lets the installer write an X configuration for the nvidia GPU. Keep `no` on laptops where the integrated GPU drives the screens, the generated configuration breaks the desktop there. | no  |
| publicKeyFilePath  | Path to the public part of the key pair which has to have been previously enrolled in the MOK storage. Only used with secure boot.  | /root/mok.pem  |
| privateKeyFilePath  | Path to the private part of the key pair which has to have been previously enrolled in the MOK storage. Only used with secure boot.  | /root/mok.priv |

### 2. Update and install the driver
Switch to a text console (e.g. Ctrl+Alt+F3), login as root and execute the `driver-update.sh`
script. The script stops the display manager, which also ends any terminal running inside the
graphical session.

The script
1. installs `dkms` and the kernel headers meta package, so the module can be rebuilt for future kernels.
2. downloads the driver with curl and verifies its checksums.
3. purges a driver installed from the distribution's packages (every installed package whose
   name contains `nvidia`, `libcuda` or `libnvcuvid`). Check the list apt shows before confirming.
4. blacklists nouveau if no blacklist is left.
5. stops the display manager and unloads the old kernel modules. If a module is still in use,
   reboot and run the script again.
6. runs the installer with `--dkms` and the configured kernel module type.

If secure boot is enabled, you need to provide the passphrase to the key pair which has been
enrolled in the MOK storage before the installer runs. If you have not secured the key pair
with a passphrase just press enter.

Reboot after the installation has finished.
