{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

{
  options.config'.steam.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };
}
