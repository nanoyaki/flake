{
  self,
  lib,
  lib',
  config,
  username,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    types
    ;

  inherit (lib') mkEnabledOption;

  cfg = config.services.media-easify;
in

{
  options.services.media-easify = {
    enable = mkEnabledOption "media services";

    group = mkOption {
      type = types.str;
      default = "arr-stack";
    };
  };

  imports = with self.nixosModules; [
    vopono
    caddy
    homepage-images
    homepage
    radarr
    prowlarr
    jellyseerr
    lidarr
    bazarr
    sonarr
    sabnzbd
    transmission
    jellyfin
    immich
    home-assistant
    paperless
    vaultwarden
  ];

  config = mkIf cfg.enable {
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

    services.vopono = {
      enable = true;

      configFile = config.sec."vopono/wireguard.conf".path;
      protocol = "Wireguard";
    };

    users.groups = mkIf (cfg.group == "arr-stack") {
      arr-stack = { };
    };
    users.users.${username}.extraGroups = lib.singleton cfg.group;
  };
}
