{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:

{
  sec = {
    "woodpecker/forgejo/clientId" = { };
    "woodpecker/forgejo/clientSecret" = { };
    "woodpecker/metrics/apiToken" = { };
    "woodpecker/agents/native/secret" = { };
    "woodpecker/agents/docker/secret" = { };
  };

  services.woodpecker-server = {
    enable = true;
    package = pkgs.woodpecker-server;

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
      config.sec."woodpecker/metrics/apiToken".path
    ];
  };

  services.woodpecker-agents.agents = {
    "native" = {
      enable = true;
      package = pkgs.woodpecker-agent;

      environment = {
        WOODPECKER_SERVER = "localhost:9000";
        WOODPECKER_MAX_WORKFLOWS = "24";
        WOODPECKER_BACKEND = "local";
        WOODPECKER_FILTER_LABELS = "platform=linux/amd64,hostname=theless.one,backend=local,repo=*";
      };

      environmentFile = [ config.sec."woodpecker/agents/native/secret".path ];

      path = with pkgs; [
        git
        git-lfs
        woodpecker-plugin-git

        bash
        coreutils
        gawk
        which
        iputils

        nix
        openssh
        statix
        nix-fast-build
        nvd
        inputs'.rebuild-maintenance.packages.rebuild-maintenance
      ];
    };

    "docker" = {
      enable = true;
      package = pkgs.woodpecker-agent;

      extraGroups = [ "podman" ];

      environment = {
        WOODPECKER_SERVER = "localhost:9000";
        WOODPECKER_MAX_WORKFLOWS = "4";
        WOODPECKER_BACKEND = "docker";
        DOCKER_HOST = "unix:///run/podman/podman.sock";
        WOODPECKER_FILTER_LABELS = "platform=linux/amd64,hostname=theless.one,backend=docker,repo=*";
      };

      environmentFile = [ config.sec."woodpecker/agents/docker/secret".path ];
    };
  };

  services.openssh.knownHosts."codeberg.org".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";

  services'.caddy.reverseProxies."woodpecker.theless.one".port = lib.strings.toInt (
    lib.strings.removePrefix ":" config.services.woodpecker-server.environment.WOODPECKER_SERVER_ADDR
  );

  services'.homepage.categories.Code.services.Woodpecker = rec {
    description = "CI/CD engine";
    icon = "woodpecker-ci.svg";
    href = "https://woodpecker.theless.one";
    siteMonitor = href;
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
    dockerCompat = true;
  };

  networking.firewall.interfaces."podman0" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };

  systemd.services.woodpecker-agent-native.after = [ "woodpecker-server.service" ];
  systemd.services.woodpecker-agent-docker = {
    after = [
      "podman.socket"
      "woodpecker-server.service"
    ];

    # might break deployment
    serviceConfig.BindPaths = [ "/run/podman/podman.sock" ];
  };
}
