{
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (inputs) nur;
in

{
  imports = [
    nur.nixosModules.nur
  ];

  nix.settings.trusted-substituters = [ "https://prismlauncher.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
  ];

  # sudo setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    extraPackages = with pkgs; [ gamescope ];
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      (proton-ge-bin.overrideAttrs (
        finalAttrs: _: {
          version = "GE-Proton9-16";
          src = pkgs.fetchzip {
            url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
            hash = "sha256-n/pU5bAr78Hawo8BMk7VW8uK0FjVsBJGMf78zRMGFPQ=";
          };
        }
      ))
      (proton-ge-bin.overrideAttrs (
        finalAttrs: _: {
          version = "GE-Proton8-5";
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
      osu-lazer-bin
      # (config.nanoLib.overrideAppimageTools osu-lazer-bin (rec {
      #   version = "2024.1009.1";
      #   src = pkgs.fetchurl {
      #     url = "https://github.com/ppy/osu/releases/download/${version}/osu.AppImage";
      #     hash = "sha256-2H2SPcUm/H/0D9BqBiTFvaCwd0c14/r+oWhyeZdNpoU=";
      #   };
      # }))

      # Emulation
      dolphin-emu
      cemu
    ])
    ++ [
      inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
      config.nur.repos.aprilthepink.suyu-mainline
    ];

  programs.gamemode.enable = true;

  environment.variables.VDPAU_DRIVER = "radeonsi";
}
