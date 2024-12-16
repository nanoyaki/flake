{
  pkgs,
  config,
  ...
}:

let
  overrideVer =
    pkg: version: hash:
    pkg.overrideAttrs (
      finalAttrs: _: {
        inherit version;
        src = pkgs.fetchzip {
          inherit hash;
          url = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-src.tar.gz";
          stripRoot = false;
        };
      }
    );

  agentPkg =
    overrideVer pkgs.woodpecker-agent "3.0.0-rc.0"
      "sha256-I+5RITnYovpNDl0QyFUnv1dPf/21Ykb3GrtbCxp55VA=";

  serverPkg =
    overrideVer pkgs.woodpecker-server "3.0.0-rc.0"
      "sha256-I+5RITnYovpNDl0QyFUnv1dPf/21Ykb3GrtbCxp55VA=";
in

{
  sec = {
    "woodpecker/forgejo/clientId" = { };
    "woodpecker/forgejo/clientSecret" = { };
    "woodpecker/agents/native/secret" = { };
    "woodpecker/agents/docker/secret" = { };
  };

  services.woodpecker-server = {
    enable = true;
    package = serverPkg;

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

  services.woodpecker-agents.agents = {
    "native" = {
      enable = true;
      package = agentPkg;

      environment = {
        WOODPECKER_SERVER = "localhost:9000";
        WOODPECKER_MAX_WORKFLOWS = "1";
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

        nix
        openssh
      ];
    };

    "docker" = {
      enable = true;
      package = agentPkg;

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

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.interfaces."podman0" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
