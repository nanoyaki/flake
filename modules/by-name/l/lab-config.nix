{
  self,
  lib,
  lib',
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    ;

  inherit (lib) mkIf;
in

lib'.modules.mkModule {
  name = "lab-config";

  options.arr = {
    group = mkDefault "arr-stack" mkStrOption;
    home = mkDefault "/home/arr-stack" mkPathOption;
  };

  specialArgs = [ "username" ];
  config =
    {
      cfg,
      config,
      username,
      ...
    }:

    {
      assertions = [
        {
          assertion = config.sops.secrets ? "vopono/wireguard.conf";
          message = ''
            The default sops file must have a wireguard configuration under "vopono/wireguard.conf"

            ```yaml
              vopono:
                wireguard.conf: |
                  ...
            ```
          '';
        }
      ];

      sec."vopono/wireguard.conf".owner = "vopono";

      services'.vopono = {
        configFile = config.sec."vopono/wireguard.conf".path;
        protocol = "Wireguard";
      };

      users.groups = mkIf (cfg.arr.group == "arr-stack") {
        arr-stack = { };
      };
      users.users.${username}.extraGroups = lib.singleton cfg.arr.group;
    };

  imports = with self.nixosModules; [
    firewall
    vopono
    caddy
    homepage-images
    homepage
    radarr
    flaresolverr
    prowlarr
    jellyseerr
    lidarr
    bazarr
    sonarr
    whisparr
    sabnzbd
    transmission
    jellyfin
    immich
    home-assistant
    paperless
    vaultwarden
  ];
}
