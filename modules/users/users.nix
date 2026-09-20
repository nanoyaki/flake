{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.users ];
  };

  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.users ];
  };

  modules.nixos.users = {
    users.mutableUsers = false;
  };
}
