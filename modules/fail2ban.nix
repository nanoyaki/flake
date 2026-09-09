{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.fail2ban ];
  };

  modules.nixos.fail2ban = {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime-increment.enable = true;
    };
  };
}
