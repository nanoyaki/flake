{
  pkgs,
  config,
  inputs',
  ...
}:

let
  webPkg = "${inputs'.discord-events-to-ics.packages.default}/share/php/discord-events-to-ics";
  app = "nanoyaki-events";
  home = "/var/www/${app}";
in

{
  sec."caddy/${app}/environment".owner = config.services.caddy.user;
  services.caddy.virtualHosts."events.austria.nanoyaki.space".extraConfig = ''
    root * ${home}/public

    encode zstd gzip
    file_server

    php_fastcgi unix${config.services.phpfpm.pools.${app}.socket} {
      root ${home}/public

      import ${config.sec."caddy/${app}/environment".path}
      env CACHE_DIR "${home}/cache"

      resolve_root_symlink
    }

    @dotfiles {
      not path /.well-known/*
      path /.*
    }
    redir @dotfiles /
  '';
  users.users.${config.services.caddy.user}.extraGroups = [ app ];

  home-manager.users.${app}.home = {
    username = app;
    homeDirectory = home;
    inherit (config.system) stateVersion;

    file = {
      "public".source = "${webPkg}/public";
      "src".source = "${webPkg}/src";
      "vendor".source = "${webPkg}/vendor";
    };
  };

  systemd.tmpfiles.settings."10-${app}"."${home}/cache".d = {
    user = app;
    group = app;
    mode = "0770";
  };

  users.groups.${app} = { };
  users.users.${app} = {
    isSystemUser = true;
    group = app;
    inherit home;
    homeMode = "770";
  };

  services.phpfpm.pools.${app} = {
    user = app;
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
      "php_admin_value[error_log]" = "/var/log/phpfpm.events.nanoyaki.space.log";
      "php_admin_flag[log_errors]" = "on";
      "catch_workers_output" = true;
    };
  };
}
