{ username, ... }:

{
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nanoflake.localization = {
    language = "en_US";
    locale = "en_US.UTF-8";
    extraLocales = [
      "de_DE.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };

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
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  deployment = {
    targetUser = username;
    targetHost = "192.168.8.101";
    privateKeyName = "deploymentYuri";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIpBykDxGMyZOdW7ECncYK9p6IseXzOnREmb9QCSG9Bn";
    knownHosts = [
      "192.168.8.105"
      "192.168.8.2"
    ];
    extraFlags = [
      "--use-remote-sudo"
      "--print-build-logs"
    ];
  };

  console.keyMap = "de";
  system.stateVersion = "25.05";
  hm.home.stateVersion = "25.05";
}
