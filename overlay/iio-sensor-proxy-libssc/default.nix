{
  iio-sensor-proxy,
  fetchFromGitLab,
  lib,
  libssc,
  libqmi,
  protobufc,
}: let
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    sparseCheckout = ["temp/iio-sensor-proxy"];
    rev = "f127ff65405a04e1f49ee90c5c980f853c324e89";
    hash = "sha256-DCJnO8I10ODzFBG21ciZxSaWwYcCFKXMGEUDlFaVczA=";
  };
  # From https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/master/temp/iio-sensor-proxy/APKBUILD
  patchNames = [
    "0001-iio-sensor-proxy-depend-on-libssc.patch"
    "0002-proximity-support-SSC-proximity-sensor.patch"
    "0003-light-support-SSC-light-sensor.patch"
    "0004-accelerometer-support-SSC-accelerometer-sensor.patch"
    "0005-compass-support-SSC-compass-sensor.patch"
    "0006-data-add-libssc-udev-rules.patch"
    "0007-data-iio-sensor-proxy.service.in-add-AF_QIPCRTR.patch"
    "0008-drv-ssc-implement-set_polling.patch"
    "0009-tests-integration-test-add-SSC-sensors.patch"
  ];
in
  iio-sensor-proxy.overrideAttrs (prevAttrs: {
    patches =
      (prevAttrs.patches or [])
      ++ builtins.map (patchName: "${pmaports}/temp/iio-sensor-proxy/${patchName}") patchNames;
    buildInputs =
      prevAttrs.buildInputs
      ++ [
        libssc
        libqmi
        protobufc
      ];
    mesonFlags = prevAttrs.mesonFlags ++ [(lib.mesonBool "ssc-support" true)];
  })
