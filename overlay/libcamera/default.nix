{
  libcamera,
  fetchFromGitLab,
}: let
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    sparseCheckout = ["temp/libcamera"];
    rev = "9f93a01375a133d3ee290486bdf0b5558cc5a1a3";
    hash = "sha256-J84qQijuhjeCoMIfvftj2xzfDUn2IEKtM5mQyXsxw8I=";
  };
  # From https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/master/temp/libcamera/APKBUILD
  patchNames = [
    "0001-libcamera-simple-Enable-softwareISP-for-the-librem5.patch"
    "0002-libcamera-simple-Force-disable-softwareISP-for-milli.patch"
    "0003-libcamera-simple-Enable-softISP-for-the-Pinephone.patch"
    "0004-libcamera-simple-Skip-hwISP-formats-if-swISP-is-acti.patch"
    "0005-pipeline-simple-Consider-output-sizes-when-choosing-.patch"
    "0006-pipeline-simple-Increase-internal-buffer-count-to-fo.patch"
    "0007-ipa-simple-Add-tuning-file-for-IMX355.patch"
    "0008-ipa-simple-Add-tuning-file-for-IMX363.patch"
    "0009-ipa-simple-Add-tuning-file-for-s5k3l6xx.patch"
    "0010-ipa-simple-Add-tuning-file-for-hi846.patch"
    "0011-ipa-simple-Add-tuning-file-for-IMX371.patch"
    "0012-ipa-simple-Add-tuning-file-for-IMX376.patch"
    "0013-libcamera-software_isp-Work-around-bug-259.patch"
  ];
in
  libcamera.overrideAttrs (finalAttrs: prevAttrs: {
    patches =
      prevAttrs.patches or [] 
      ++ builtins.map (patchName: "${pmaports}/temp/libcamera/${patchName}") patchNames;
  })
