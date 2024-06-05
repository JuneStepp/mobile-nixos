{ config, pkgs, ... }:

{
  imports = [
    ../families/sdm845-mainline
  ];

  mobile.device.name = "oneplus-enchilada";
  mobile.device.identity = {
    name = "OnePlus 6";
    manufacturer = "OnePlus";
  };
  mobile.device.supportLevel = "supported";

  mobile.hardware = {
    ram = 1024 * 8;
    screen = {
      width = 1080; height = 2280;
    };
  };

  mobile.device.firmware = pkgs.callPackage ./firmware {};

  mobile.system.android.device_name = "OnePlus6";

  hardware.sensor.iio.enable = true;
  mobile.hexagonrpcd = {
    enable = true;
    root = "${config.mobile.device.firmware.baseFw}/usr/share/qcom/sdm845/OnePlus/oneplus6";
    services.sdsp.enable = true;
  };
  systemd.services.iio-sensor-proxy = {
    requires = [ "hexagonrpcd-sdsp.service" ];
    after = [ "hexagonrpcd-sdsp.service" ];
    # hexagonrpcd-sdsp.service is marked active too early
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };
  };
  services.udev.extraRules = ''
    # iio-sensor-proxy with libssc: accelerometer mount matrix
    SUBSYSTEM=="misc", KERNEL=="fastrpc-*", ENV{ACCEL_MOUNT_MATRIX}+="-1, 0, 0; 0, -1, 0; 0, 0, -1"
  '';
}
