{
  iio-sensor-proxy,
  fetchFromGitLab,
  lib,
  libssc,
  libqmi,
  protobufc,
}:
let
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    sparseCheckout = [ "temp/iio-sensor-proxy" ];
    rev = "b2399f7f09daab4bbcfe7c3f7c8bc84a81b50a4f";
    hash = "sha256-IbsCFsjFYytNhvklbG+xzl+ndgOEh/Yk9d3rGPlDklc=";
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
    # "0010-drv-iio-buffer-relocate-the-.discover-method-to-brin.patch"
    # "0011-buffer_drv_data_new-rework-trigger_name-handling.patch"
    # "0012-iio-buffer-attempt-to-read-from-buffer-during-sensor.patch"
    # "0013-integration-test-add-test-for-sensors-that-report-no.patch"

  ];
in
iio-sensor-proxy.overrideAttrs (prevAttrs: {
  patches =
    (prevAttrs.patches or [ ])
    ++ builtins.map (patchName: "${pmaports}/temp/iio-sensor-proxy/${patchName}") patchNames;
  buildInputs = prevAttrs.buildInputs ++ [
    libssc
    libqmi
    protobufc
  ];
  mesonFlags = prevAttrs.mesonFlags ++ [ (lib.mesonBool "ssc-support" true) ];
})
