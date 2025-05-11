{ self, ... }:

{
  imports = [
    self.nixosModules.media-easify
    ./caddy.nix
    ./ssh.nix
    ./suwayomi.nix
    ./forgejo.nix
    ./minecraft
    ./woodpecker.nix
    ./dynamicdns.nix
    ./syncthing.nix
    ./steam.nix
    ./immich.nix
    ./nix-serve.nix
    ./uptime-kuma.nix
  ];

  services.caddy-easify.baseDomain = "theless.one";

  services.media-easify.services = {
    lidarr.enable = false;
    paperless.enable = false;
    home-assistant.enable = false;
  };

  services.homepage-easify = {
    categories = {
      Media.before = "Services";
      Services.before = "Code";
    };

    glances.widgets = [
      {
        Info = {
          metric = "info";
          chart = true;
        };
      }
      {
        "CPU usage" = {
          metric = "cpu";
          chart = true;
        };
      }
      {
        "Memory usage" = {
          metric = "memory";
          chart = true;
        };
      }
      {
        "Storage usage" = {
          metric = "fs:/";
          chart = true;
        };
      }
      {
        "Disk I/O" = {
          metric = "disk:nvme0n1";
          chart = true;
        };
      }
      {
        "Network usage" = {
          metric = "network:enp6s0";
          chart = true;
        };
      }
    ];
  };

  services.caddy-easify.reverseProxies."https://transmission.theless.one".userEnvVar = "shared";
}
