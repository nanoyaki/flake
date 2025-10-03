{ config, ... }:

{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
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
