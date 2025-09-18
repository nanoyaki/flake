{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (inputs) copyparty;
  cfg = config.services.copyparty;

  defaults.flags = {
    fka = 32;
    dks = true;
  };

  mkPrivateVol = user: {
    path = "/mnt/raid/copyparty-priv/${user}";
    access.A = user;
    inherit (defaults) flags;
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
      theme = 2;

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

    accounts = {
      Hana.passwordFile = config.sops.secrets."copyparty/hana".path;
      Sebi.passwordFile = config.sops.secrets."copyparty/sebi".path;
      Thomas.passwordFile = config.sops.secrets."copyparty/thomas".path;
      Ashley.passwordFile = config.sops.secrets."copyparty/ashley".path;
    };

    volumes = {
      "/" = {
        path = "/mnt/raid/copyparty/root";
        access = {
          r = "@acct";
          A = "Hana";
        };
        inherit (defaults) flags;
      };

      "/ashley" = mkPrivateVol "Ashley";
      "/hana" = mkPrivateVol "Hana";
      "/thomas" = mkPrivateVol "Thomas";
      "/sebi" = mkPrivateVol "Sebi";

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
    };
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
