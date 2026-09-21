{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.steam ];
  };

  modules.nixos.steam =
    { pkgs, ... }:

    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    };

  modules.nixos.nix =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.steam.enable {
        nixpkgs.allowUnfreePkgNames = [
          "steam"
          "steam-unwrapped"
        ];
      };
    };
}
