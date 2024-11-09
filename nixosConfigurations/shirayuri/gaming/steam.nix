{ pkgs, ... }:

let
  mkProtonGeBin =
    version: hash:
    (pkgs.proton-ge-bin.overrideAttrs {
      inherit version;
      src = pkgs.fetchzip {
        url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
        inherit hash;
      };
    });
in

{

  # sudo setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    extraPackages = with pkgs; [ gamescope ];
    gamescopeSession.enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
      (mkProtonGeBin "GE-Proton9-16" "sha256-n/pU5bAr78Hawo8BMk7VW8uK0FjVsBJGMf78zRMGFPQ=")
      (mkProtonGeBin "GE-Proton8-5" "sha256-YeibTA2z69bNE3V/sgFHOHaxl0Uf77unQQc7x2w/1AI=")
    ];
  };
}
