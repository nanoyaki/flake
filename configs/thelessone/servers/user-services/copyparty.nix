{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (inputs) copyparty;
  cfg = config.services.copyparty;
in

{
  imports = [ copyparty.nixosModules.default ];
  nixpkgs.overlays = [ copyparty.overlays.default ];

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
    };
    volumes."/" = {
      path = "/mnt/raid/copyparty";
      access.r = "*";
      flags = {
        fka = 32;
        dks = true;
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
