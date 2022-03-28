variablesScript=$(basename "$0")

baseUrl=https://download.nvidia.com/XFree86/Linux-x86_64/
fileNamePrefix=NVIDIA-Linux-x86_64-
fileNameSuffix=.run
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

  read -e -i "$publicKeyFilePath" -p "Path of the public part of the Machine Owner Key used to sign the driver: " publicKeyFilePathInput
  publicKeyFilePath=${publicKeyFilePathInput:-$publicKeyFilePath}
  sed -i -E "s|^(publicKeyFilePath=).*$|\1$publicKeyFilePath|g" "$variablesScript"

  read -e -i "$privateKeyFilePath" -p "Path of the private part of the Machine Owner Key used to sign the driver: " privateKeyFilePathInput
  privateKeyFilePath=${privateKeyFilePathInput:-$privateKeyFilePath}
  sed -i -E "s|^(privateKeyFilePath=).*$|\1$privateKeyFilePath|g" "$variablesScript"

fi
