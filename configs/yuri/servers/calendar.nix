{
  pkgs,
  config,
  inputs',
  self,
  ...
}:

let
  webPkg = "${inputs'.discord-events-to-ics.packages.default}/share/php/discord-events-to-ics";
  home = "/var/lib/caddy/nanoyaki-events";
in

{
  imports = [ self.nixosModules.dynamicdns ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  sec."caddy/nanoyaki-events/environment".owner = config.services.caddy.user;
  services.caddy = {
    enable = true;
    logFormat = ''
      format console
      level INFO
    '';

    environmentFile = "/run/secrets/caddy/nanoyaki-events/environment";

    virtualHosts."events.nanoyaki.space".extraConfig = ''
      root * ${webPkg}/public

      encode zstd gzip
      file_server

      php_fastcgi unix${config.services.phpfpm.pools.nanoyaki-events.socket} {
        root ${webPkg}/public

        env GUILD_ID {env.GUILD_ID}
        env BOT_TOKEN {env.BOT_TOKEN}
        env CACHE_DIR "${home}/cache"
        env LOG_PATH "${home}/logs"
        env LOG_LEVEL "info"

        resolve_root_symlink
      }

      @dotfiles {
        not path /.well-known/*
        path /.*
      }
      redir @dotfiles /
    '';
  };
  users.users.${config.services.caddy.user}.extraGroups = [ "nanoyaki-events" ];

  systemd.tmpfiles.settings."10-nanoyaki-events" =
    let
      dirCfg = {
        user = "nanoyaki-events";
        group = "nanoyaki-events";
        mode = "0770";
      };
    in
    {
      ${home}.d = dirCfg;
      "${home}/cache".d = dirCfg;
      "${home}/logs".d = dirCfg;
      "/var/log/phpfpm".d = dirCfg;
    };

  users.groups.nanoyaki-events = { };
  users.users.nanoyaki-events = {
    isSystemUser = true;
    group = "nanoyaki-events";
    inherit home;
    homeMode = "770";
  };

  services.phpfpm.pools.nanoyaki-events = {
    user = "nanoyaki-events";

    phpPackage = pkgs.php84;

    settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
      "pm" = "dynamic";
      "pm.max_children" = 75;
      "pm.start_servers" = 10;
      "pm.min_spare_servers" = 5;
      "pm.max_spare_servers" = 20;
      "pm.max_requests" = 500;
      "php_flag[display_errors]" = "off";
      "php_admin_value[error_log]" = "/var/log/phpfpm/phpfpm.events.nanoyaki.space.log";
      "php_admin_flag[log_errors]" = "on";
      "catch_workers_output" = true;
    };
  };

  sec."dynamicdns/nanoyaki.space" = { };
  services.namecheapDynDns = {
    enable = true;

    domains."nanoyaki.space" = {
      subdomains = [ "events" ];
      passwordFile = config.sec."dynamicdns/nanoyaki.space".path;
    };
  };
}
