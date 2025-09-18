{
  inputs,
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    nameValuePair
    mapAttrs'
    toLower
    attrNames
    filter
    hasPrefix
    listToAttrs
    ;
  inherit (inputs) copyparty;
  cfg = config.services.copyparty;

  defaults.flags = {
    fka = 32;
    dks = true;
  };
in

{
  imports = [ copyparty.nixosModules.default ];
  nixpkgs.overlays = [ copyparty.overlays.default ];

  sops.secrets = {
    "copyparty/hana".owner = cfg.user;
    "copyparty/sebi".owner = cfg.user;
    "copyparty/thomas".owner = cfg.user;
    "copyparty/ashley".owner = cfg.user;
    "copyparty/nik".owner = cfg.user;
  };

  systemd.services.copyparty.serviceConfig.BindPaths = [ "/run/sockets" ];
  services.copyparty = {
    enable = true;
    package = pkgs.copyparty.override { inherit (pkgs) partftpy; };
    mkHashWrapper = true;
    settings = {
      # Server options
      i = "unix:770:${cfg.group}:/run/sockets/copyparty.sock";
      hist = "/var/cache/copyparty";
      shr = "/share";
      no-reload = true;
      name = "Theless.one files";
      theme = 0;

      # Password options
      chpw = true;
      ah-alg = "argon2";

      # Media options
      allow-flac = true;

      # Global options
      hardlink-only = true;
      magic = true;
      e2dsa = true;
      e2vp = true;
      df = "100g";
      # GDPR
      no-db-ip = true;
      xdev = true;
      xvol = true;
      grid = true;
      no-dot-ren = true;
      no-robots = true;
      force-js = true;
      og-ua = "Discordbot";
      fk = 24;
      dk = 48;
      chmod-f = 640;
      chmod-d = 750;
      ban-pw = "3,60,1440";
      grp-all = "acct";
      no-dupe = true;
    };

    accounts = listToAttrs (
      map (
        attr:
        nameValuePair (lib'.toUppercase (lib.removePrefix "copyparty/" attr)) {
          passwordFile = config.sops.secrets.${attr}.path;
        }
      ) (filter (attr: hasPrefix "copyparty/" attr) (attrNames config.sops.secrets))
    );

    volumes = {
      "/" = {
        path = "/mnt/raid/copyparty/root";
        access = {
          r = "@acct";
          A = "Hana";
        };
        inherit (defaults) flags;
      };

      "/shared" = {
        path = "/mnt/raid/copyparty/shared";
        access = {
          "rwmd." = "@acct";
          A = [
            "Hana"
            "Thomas"
          ];
        };
        inherit (defaults) flags;
      };

      "/shared-public-download" = {
        path = "/mnt/raid/copyparty/public";
        access = {
          "rwmd." = "@acct";
          A = [
            "Hana"
            "Thomas"
          ];
          g = "*";
        };
      };
    }
    // mapAttrs' (
      user: _:
      nameValuePair "/${toLower user}" {
        path = "/mnt/raid/copyparty-priv/${user}";
        access.A = user;
        inherit (defaults) flags;
      }
    ) cfg.accounts;
  };

  systemd.tmpfiles.settings.sockets-dir."/run/sockets".d = {
    inherit (cfg) user group;
    mode = "770";
  };

  systemd.services.caddy.serviceConfig.BindPaths = [ "/run/sockets/copyparty.sock" ];
  users.users.${config.services.caddy.user}.extraGroups = [ cfg.group ];
  config'.caddy.vHost.${config.config'.caddy.genDomain "files"}.extraConfig = ''
    reverse_proxy unix//run/sockets/copyparty.sock
  '';
}
