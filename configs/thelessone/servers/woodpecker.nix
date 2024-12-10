{ pkgs, config, ... }:

{
  sec = {
    "woodpecker/forgejo/clientId" = { };
    "woodpecker/forgejo/clientSecret" = { };
    "woodpecker/agents/native/secret" = { };
    "woodpecker/agents/docker/secret" = { };
  };

  services.woodpecker-server = {
    enable = true;

    environment = {
      WOODPECKER_OPEN = "true";
      WOODPECKER_HOST = "https://woodpecker.theless.one";
      WOODPECKER_SERVER_ADDR = ":3007";
      WOODPECKER_GRPC_ADDR = ":9000";

      WOODPECKER_FORGEJO = "true";
      WOODPECKER_FORGEJO_URL = "https://git.theless.one";

      WOODPECKER_ADMIN = "nanoyaki";
    };

    environmentFile = [
      config.sec."woodpecker/forgejo/clientId".path
      config.sec."woodpecker/forgejo/clientSecret".path
    ];
  };

  users.groups."woodpecker-tmp" = { };
  systemd.tmpfiles.settings."10-woodpecker"."/var/lib/woodpecker/tmp".d = {
    group = "woodpecker-tmp";
    mode = "0770";
  };

  services.woodpecker-agents.agents = {
    "native" = {
      enable = true;

      extraGroups = [ "woodpecker-tmp" ];

      environment = {
        WOODPECKER_SERVER = "localhost:9000";
        WOODPECKER_MAX_WORKFLOWS = "1";
        WOODPECKER_BACKEND = "local";
        WOODPECKER_BACKEND_LOCAL_TEMP_DIR = "/var/lib/woodpecker/tmp";
      };

      environmentFile = [ config.sec."woodpecker/agents/native/secret".path ];

      path = with pkgs; [
        git
        git-lfs
        woodpecker-plugin-git

        bash
        coreutils

        nix
      ];
    };

    "docker" = {
      enable = true;

      extraGroups = [ "podman" ];

      environment = {
        WOODPECKER_SERVER = "localhost:9000";
        WOODPECKER_MAX_WORKFLOWS = "4";
        WOODPECKER_BACKEND = "docker";
        DOCKER_HOST = "unix:///run/podman/podman.sock";
      };

      environmentFile = [ config.sec."woodpecker/agents/docker/secret".path ];
    };
  };

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.interfaces."podman0" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
