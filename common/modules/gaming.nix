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
        (proton-ge-bin.overrideAttrs (
          finalAttrs: _: {
            version = "GE-Proton8-27";
            src = pkgs.fetchzip {
              url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
              hash = "sha256-YeibTA2z69bNE3V/sgFHOHaxl0Uf77unQQc7x2w/1AI=";
            };
          }
        ))
      ];
    };

    environment.systemPackages =
      (with pkgs; [
        # Launchers
        bottles
        cartridges
        lutris

        # Util
        mangohud

        # Games
        (osu-lazer-bin.override {
          appimageTools = pkgs.appimageTools // {
            wrapType2 =
              args:
              pkgs.appimageTools.wrapType2 (
                args
                // rec {
                  version = "2024.1009.1";
                  src = pkgs.fetchurl {
                    url = "https://github.com/ppy/osu/releases/download/${version}/osu.AppImage";
                    hash = "sha256-2H2SPcUm/H/0D9BqBiTFvaCwd0c14/r+oWhyeZdNpoU=";
                  };
                }
              );
          };
        })

        # Emulation
        dolphin-emu # I own a Wii and every game I play on this I dumped myself
        cemu # Same goes for the WiiU
        config.nur.repos.aprilthepink.suyu-mainline # Same goes for the Switch
      ])
      ++ [
        inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
      ];

    programs.gamemode.enable = true;
  };
}
