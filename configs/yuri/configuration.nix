{ config, ... }:

{
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  security.sudo.extraRules = [
    {
      users = [ config.nanoSystem.mainUserName ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  console.keyMap = "de";
}
