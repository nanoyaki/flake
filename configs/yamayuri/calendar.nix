{
  pkgs,
  config,
  inputs',
  ...
}:

let
  webPkg = "${inputs'.discord-events-to-ics.packages.default}/share/php/discord-events-to-ics";
  home = "/var/lib/caddy/nanoyaki-events";
  inherit (config.services.caddy) user;
in

{
  sops.secrets = {
    "caddy-env/guildId".owner = user;
    "caddy-env/botToken".owner = user;
  };

  users.users.${user}.extraGroups = [ "nanoyaki-events" ];
  services.caddy.virtualHosts."events.nanoyaki.space" = {
    listenAddresses = [ "10.0.0.3" ];
    useACMEHost = "events.nanoyaki.space";
    extraConfig = ''
      root * ${webPkg}/public

      encode zstd gzip
      file_server

      php_fastcgi unix/${config.services.phpfpm.pools.nanoyaki-events.socket} {
        root ${webPkg}/public

        env GUILD_ID {file.${config.sops.secrets."caddy-env/guildId".path}}
        env BOT_TOKEN {file.${config.sops.secrets."caddy-env/botToken".path}}
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

  systemd.tmpfiles.settings."10-nanoyaki-events" = {
    "${home}/cache".d = {
      user = "nanoyaki-events";
      group = "nanoyaki-events";
      mode = "0770";
    };

    "${home}/logs".d = {
      user = "nanoyaki-events";
      group = "nanoyaki-events";
      mode = "0770";
    };
  };

  users.groups.nanoyaki-events = { };
  users.users.nanoyaki-events = {
    isSystemUser = true;
    group = "nanoyaki-events";
    inherit home;
    homeMode = "770";
  };

  services.phpfpm = {
    phpPackage = pkgs.php84;
    phpOptions = ''
      memory_limit = 256M
      display_errors = 0
    '';

    pools.nanoyaki-events = {
      user = "nanoyaki-events";
      settings = {
        "listen.owner" = user;
        "listen.group" = config.services.caddy.group;
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 1;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 5;
        "pm.max_requests" = 50;
        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };
    };
  };
}
