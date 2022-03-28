# nvidia driver updater

Installing the nvidia linux driver on a machine that has secure boot enabled [is hard enough](https://askubuntu.com/questions/1023036/how-to-install-nvidia-driver-with-secure-boot-enabled).
Only seeing the terminal after a kernel update after having gone through the hassle of setting
up the driver is mildly infuriating. The easiest solution to have a working desktop environment
is to re-install the driver after the kernel update. It's not so easy if you are only looking
at a terminal though.

To overcome the struggle of manually installing the driver after each kernel update, you can
use this script.

## Assumptions
1. You are running debian.
2. You already have enrolled a key pair to MOK.
3. You are online.

## Usage
### 1. Set up variables
Run `/bin/bash driver-update-variables.sh`. This will interactively set the following variables:

| Variable  | Description  | Default  |
|---|---|---|
| baseUrl  | URL to nvidia's driver directory. Other architectures are listed [here](http://download.nvidia.com/XFree86/). | http://download.nvidia.com/XFree86/Linux-x86_64/  |
| fileNamePrefix  | Prefix of the driver file name. Adjust according to your architecture. | NVIDIA-Linux-x86_64-  |
| fileNameSuffix  |  Suffix of the driver file name. | .run  |
| publicKeyFilePath  | Path to the public part of the key pair which has to have been previously enrolled in the MOK storage.  | /root/mok.pem  |
| privateKeyFilePath  | Path to the private part of the key pair which has to have been previously enrolled in the MOK storage.  | /root/mok.priv |

### 2. Update and install the latest driver
Login to a root shell and execute the `driver-update.sh` script. 

The script depends on curl to query the base url, it then uses pup to transform the curl 
output to json and finally filters that using jq. After retrieving the latest file name 
wget is used to download it.

Once the download has finished, you need to provide the passphrase to the key pair which 
has been enrolled in the MOK storage. If you have not secured the key pair with a 
passphrase just press enter.

The script then executes the downloaded file and provides all the parameters needed to install
and sign the driver. After the installation is complete, `nvidia-xconfig` is invoked.
