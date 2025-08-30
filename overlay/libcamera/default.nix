{
  libcamera,
  fetchFromGitLab,
}:
let
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    sparseCheckout = [ "temp/libcamera" ];
    rev = "a63aca69b1265861ef12a94ee7bcd761210e10d2";
    hash = "sha256-5OLGQ3LapZetnlso1Kp6fHivaTj6fJEIq5BsnRRvDz0=";
  };
  # From https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/master/temp/libcamera/APKBUILD
  patchNames = [
    "0001-libcamera-software_isp-Clarify-SwStatsCpu-setWindow-.patch"
    "0002-libcamera-software_isp-Pass-correct-y-coordinate-to-.patch"
    "0003-libcamera-software_isp-Check-processed-window-size-a.patch"
    "0004-libcamera-simple-Avoid-incorrect-arithmetic-in-AWB.patch"
    "0005-libcamera-simple-Prevent-division-by-zero-in-BLC.patch"
    "0006-libcamera-simple-Enable-softwareISP-for-the-librem5.patch"
    "0007-libcamera-simple-Force-disable-softwareISP-for-milli.patch"
    "0008-libcamera-simple-Enable-softISP-for-the-Pinephone.patch"
    "0009-libcamera-simple-Skip-hwISP-formats-if-swISP-is-acti.patch"
    "0010-pipeline-simple-Consider-output-sizes-when-choosing-.patch"
    "0011-pipeline-simple-Increase-internal-buffer-count-to-fo.patch"
    "0012-ipa-simple-Add-tuning-file-for-IMX355.patch"
    "0013-ipa-simple-Add-tuning-file-for-IMX363.patch"
    "0014-ipa-simple-Add-tuning-file-for-s5k3l6xx.patch"
    "0015-ipa-simple-Add-tuning-file-for-hi846.patch"
    "0016-ipa-simple-Add-tuning-file-for-IMX371.patch"
    "0017-ipa-simple-Add-tuning-file-for-IMX376.patch"
  ];
in
libcamera.overrideAttrs (
  finalAttrs: prevAttrs: {
    patches =
      prevAttrs.patches or [ ]
      ++ builtins.map (patchName: "${pmaports}/temp/libcamera/${patchName}") patchNames;
  }
)
