{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.gamescope ];
  };

  modules.nixos.gamescope = {
    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = true;

    programs.steam.gamescopeSession.enable = true;
  };
}
