{
  lib,
  pkgs,
  config,
  inputs,
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
    nix.settings.trusted-substituters = [ "https://prismlauncher.cachix.org" ];
    nix.settings.trusted-public-keys = [
      "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
    ];

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

    environment.systemPackages =
      (with pkgs; [
        # Launchers
        bottles
        cartridges
        lutris-unwrapped

        # Util
        mangohud

        # Games
        (mkIf cfg.withOsu osu-lazer-bin)
      ])
      ++ [
        inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
      ];

    programs.gamemode.enable = true;
  };
}
