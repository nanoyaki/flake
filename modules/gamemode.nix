{ config, ... }:

{
  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.gamemode ];
  };

  modules.nixos.gamemode = {
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general.renice = 10;
        cpu.park_cores = true;
        cpu.pin_cores = false;
      };
    };
  };
}
