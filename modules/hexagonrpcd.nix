{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption mkOption getExe types;
  cfg = config.mobile.hexagonrpcd;
in
{
  options.mobile.hexagonrpcd = {
    enable = mkEnableOption "hexagonrpcd";
    root = mkOption {
      type = types.path;
      description = lib.mdDoc ''
        Root directory of served files.
      '';
    };
    services = {
      adsp-rootpd.enable = mkEnableOption "hexagonrpcd-adsp-rootpd";
      adsp-sensorspd.enable = mkEnableOption "hexagonrpcd-adsp-sensorspd";
      sdsp.enable = mkEnableOption "hexagonrpcd-sdsp";
    };
  };

  config = mkIf cfg.enable {
    users.users.fastrpc = {
      isSystemUser = true;
      group = "fastrpc";
    };
    users.groups.fastrpc = {};

    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="fastrpc-*", OWNER="fastrpc", GROUP="fastrpc", MODE="600", TAG+="systemd"
    '';

    systemd.services.hexagonrpcd-adsp-rootpd = {
      description = "Daemon to support Qualcomm Hexagon ADSP virtual filesystem for RootPD";
      requires = ["dev-fastrpc\\x2dadsp.device"];
      after = ["dev-fastrpc\\x2dadsp.device"];
      script = ''
        "${getExe pkgs.hexagonrpcd}" -f /dev/fastrpc-adsp -d adsp -R "${cfg.root}"
      '';
      serviceConfig = {
        Restart = "always";
        RestartSec = "3";
        User = "fastrpc";
        Group = "fastrpc";
      };
      wantedBy = mkIf (cfg.services.adsp-rootpd.enable) ["multi-user.target"];
    };
    systemd.services.hexagonrpcd-adsp-sensorspd = {
      description = "Daemon to support Qualcomm Hexagon ADSP virtual filesystem for SensorPD";
      requires = ["dev-fastrpc\\x2dadsp.device"];
      after = ["dev-fastrpc\\x2dadsp.device"];
      script = ''
        "${getExe pkgs.hexagonrpcd}" -f /dev/fastrpc-adsp -d adsp -s -R "${cfg.root}"
      '';
      unitConfig = {
        # This service shouldn't be run on devices with an SDSP
        ConditionPathExists = ["!/dev/fastrpc-sdsp"];
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "3";
        User = "fastrpc";
        Group = "fastrpc";
      };
      wantedBy = mkIf (cfg.services.adsp-sensorspd.enable) ["multi-user.target"];
    };
    systemd.services.hexagonrpcd-sdsp = {
      description = "Daemon to support Qualcomm Hexagon SDSP virtual filesystem";
      requires = ["dev-fastrpc\\x2dsdsp.device"];
      after = ["dev-fastrpc\\x2dsdsp.device"];
      script = ''
        "${getExe pkgs.hexagonrpcd}" -f /dev/fastrpc-sdsp -d sdsp -s -R "${cfg.root}"
      '';
      serviceConfig = {
        Restart = "always";
        RestartSec = "3";
        User = "fastrpc";
        Group = "fastrpc";
      };
      wantedBy = mkIf (cfg.services.sdsp.enable) ["multi-user.target"];
    };
  };
}
