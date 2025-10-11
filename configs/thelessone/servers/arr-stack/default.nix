{
  lib,
  config,
  ...
}:

let
  inherit (lib) mkOption types;
in

{
  imports = [
    ./bazarr.nix
    ./flaresolverr.nix
    ./jellyseerr.nix
    ./lidarr.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sabnzbd.nix
    ./sonarr.nix
    ./whisparr.nix
  ];

  options.arr = {
    home = mkOption { type = types.path; };
    group = mkOption { type = types.str; };
  };

  config = {
    sops.secrets = {
      wireguard-private = { };
      wireguard-address = { };
      wireguard-public = { };
      wireguard-endpoint = { };
    };

    arr.home = "/mnt/raid/arr-stack";
    arr.group = "arr";

    sops.templates."wireguard.conf" = {
      owner = "vopono";
      restartUnits = [ "vopono.service" ];
      content = with config.sops.placeholder; ''
        [Interface]
        PrivateKey = ${wireguard-private}
        Address = ${wireguard-address}
        DNS = 10.64.0.1

        [Peer]
        PublicKey = ${wireguard-public}
        AllowedIps = 0.0.0.0/0, ::0/0
        Endpoint = ${wireguard-endpoint}
      '';
    };

    config'.vopono = {
      enable = true;

      configFile = config.sops.templates."wireguard.conf".path;
      protocol = "Wireguard";
    };

    users.groups.${config.arr.group} = { };
    users.users.${config.nanoSystem.mainUserName}.extraGroups = [ config.arr.group ];
  };
}
