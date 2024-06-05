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
      description = "Hexagonrpcd ADSP RootPD";
      requires = ["dev-fastrpc\\x2dadsp.device"];
      after = ["dev-fastrpc\\x2dadsp.device"];
      script = ''
        "${getExe pkgs.hexagonrpcd}" -R "${cfg.root}" -d adsp -f /dev/fastrpc-adsp
      '';
      serviceConfig = {
        User = "fastrpc";
        Group = "fastrpc";
      };
      wantedBy = mkIf (cfg.services.adsp-rootpd.enable) ["multi-user.target"];
    };
    systemd.services.hexagonrpcd-adsp-sensorspd = {
      description = "Hexagonrpcd ADSP SensorPD";
      requires = ["dev-fastrpc\\x2dadsp.device"];
      after = ["dev-fastrpc\\x2dadsp.device"];
      script = ''
        "${getExe pkgs.hexagonrpcd}" -R "${cfg.root}" -d adsp -f /dev/fastrpc-adsp -s
      '';
      serviceConfig = {
        User = "fastrpc";
        Group = "fastrpc";
      };
      wantedBy = mkIf (cfg.services.adsp-sensorspd.enable) ["multi-user.target"];
    };
    systemd.services.hexagonrpcd-sdsp = {
      description = "Hexagonrpcd SDSP";
      requires = ["dev-fastrpc\\x2dsdsp.device"];
      after = ["dev-fastrpc\\x2dsdsp.device"];
      script = ''
        "${getExe pkgs.hexagonrpcd}" -R "${cfg.root}" -d sdsp -f /dev/fastrpc-sdsp -s
      '';
      serviceConfig = {
        User = "fastrpc";
        Group = "fastrpc";
      };
      wantedBy = mkIf (cfg.services.sdsp.enable) ["multi-user.target"];
    };
  };
}
