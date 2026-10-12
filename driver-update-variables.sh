variablesScript=$(basename "$0")

baseUrl=https://download.nvidia.com/XFree86/Linux-x86_64/
fileNamePrefix=NVIDIA-Linux-x86_64-
fileNameSuffix=.run
driverVersion=latest
kernelModuleType=open
runNvidiaXconfig=no
publicKeyFilePath=/root/mok.pem
privateKeyFilePath=/root/mok.priv

if [ "$variablesScript" == "driver-update-variables.sh" ]
then

  read -e -i "$baseUrl" -p "Base directory Url provided by nvidia which contains platform specific driver releases: " baseUrlInput
  baseUrl=${baseUrlInput:-$baseUrl}
  sed -i -E "s|^(baseUrl=).*$|\1$baseUrl|g" "$variablesScript"

  read -e -i "$fileNamePrefix" -p "Driver file name prefix: " fileNamePrefixInput
  fileNamePrefix=${fileNamePrefixInput:-$fileNamePrefix}
  sed -i -E "s|^(fileNamePrefix=).*$|\1$fileNamePrefix|g" "$variablesScript"

  read -e -i "$fileNameSuffix" -p "Driver file name suffix: " fileNameSuffixInput
  fileNameSuffix=${fileNameSuffixInput:-$fileNameSuffix}
  sed -i -E "s|^(fileNameSuffix=).*$|\1$fileNameSuffix|g" "$variablesScript"

  read -e -i "$driverVersion" -p "Driver version to install, e.g. 580.126.09, latest (asks whether to install the recommended or the newest driver) or newest: " driverVersionInput
  driverVersion=${driverVersionInput:-$driverVersion}
  sed -i -E "s|^(driverVersion=).*$|\1$driverVersion|g" "$variablesScript"

  read -e -i "$kernelModuleType" -p "Kernel module type, open (Turing and newer) or proprietary (older GPUs): " kernelModuleTypeInput
  kernelModuleType=${kernelModuleTypeInput:-$kernelModuleType}
  sed -i -E "s|^(kernelModuleType=).*$|\1$kernelModuleType|g" "$variablesScript"

  read -e -i "$runNvidiaXconfig" -p "Run nvidia-xconfig after installing, yes or no (no on laptops where the integrated GPU drives the screens): " runNvidiaXconfigInput
  runNvidiaXconfig=${runNvidiaXconfigInput:-$runNvidiaXconfig}
  sed -i -E "s|^(runNvidiaXconfig=).*$|\1$runNvidiaXconfig|g" "$variablesScript"

  read -e -i "$publicKeyFilePath" -p "Path of the public part of the Machine Owner Key used to sign the driver (only used with secure boot): " publicKeyFilePathInput
  publicKeyFilePath=${publicKeyFilePathInput:-$publicKeyFilePath}
  sed -i -E "s|^(publicKeyFilePath=).*$|\1$publicKeyFilePath|g" "$variablesScript"

  read -e -i "$privateKeyFilePath" -p "Path of the private part of the Machine Owner Key used to sign the driver (only used with secure boot): " privateKeyFilePathInput
  privateKeyFilePath=${privateKeyFilePathInput:-$privateKeyFilePath}
  sed -i -E "s|^(privateKeyFilePath=).*$|\1$privateKeyFilePath|g" "$variablesScript"

fi
