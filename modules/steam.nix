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
}
