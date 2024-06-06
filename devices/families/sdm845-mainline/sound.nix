{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      sdm845-alsa-ucm = self.callPackage (
        { runCommand, fetchFromGitLab }:

        runCommand "sdm845-alsa-ucm" {
          src = fetchFromGitLab {
            name = "sdm845-alsa-ucm";
            owner = "sdm845-mainline";
            repo = "alsa-ucm-conf";
            rev = "34a4ee28abe70a5719e4a895333d0796c13ecd16"; # master
            sha256 = "sha256-9RZ6o5w60DM2CuB9lSEV6B5CAHfR+Y2yU8TppXk7KZg=";
          };
        } ''
          mkdir -p $out/share/
          ln -s $src $out/share/alsa
        ''
      ) {};
    })
  ];

  # Alsa UCM profiles
  mobile.quirks.audio.alsa-ucm-meld = true;
  environment.systemPackages = [
    pkgs.sdm845-alsa-ucm
  ];

  # Pipewire workaround
  # https://gitlab.com/postmarketOS/pmaports/-/blob/master/device/community/soc-qcom-sdm845/51-qcom-sdm845.lua
  services.pipewire.wireplumber.extraConfig."51-qcom-sdm845-workaround" = {
    "monitor.alsa.rules" = [
      {
        # PipeWire's S24LE default audio format is broken in the kernel driver
        matches = [
          { "node.name" = "~alsa_output\\..*\\.HiFi.*__sink"; }
          { "node.name" = "~alsa_input\\..*\\.HiFi.*__source"; }
        ];
        actions = {
          update-props = {
            "audio.format" = "S16LE";
            "audio.rate" = 48000;
            "api.alsa.period-size" = 4096;
            "api.alsa.period-num" = 6;
            "api.alsa.headroom" = 512;
          };
        };
      }
      {
        # Disable suspend for Voice Call devices
        matches = [
          { "node.name" = "~alsa_output\\..*\\.Voice_Call.*__sink"; }
          { "node.name" = "~alsa_input\\..*\\.Voice_Call.*__source"; }
        ];
        actions = {
          update-props = {
            "audio.format" = "S16LE";
            "session.suspend-timeout-seconds" = 0;
          };
        };
      }
    ];
  };
}
