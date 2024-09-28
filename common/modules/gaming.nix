{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom gaming options.";
    };

    withOsu = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install osu.";
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      extraPackages = with pkgs; [ gamescope ];
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    environment.systemPackages = with pkgs; [
      # Launchers
      bottles
      cartridges
      lutris-unwrapped
      prismlauncher

      # Util
      mangohud

      # Games
      (mkIf cfg.withOsu osu-lazer-bin)
    ];

    programs.gamemode.enable = true;
  };
}
