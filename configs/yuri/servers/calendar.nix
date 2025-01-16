{
  lib,
  pkgs,
  config,
  inputs',
  self,
  ...
}:

let
  webPkg = "${inputs'.discord-events-to-ics.packages.default}/share/php/discord-events-to-ics";
  home = "/var/www/nanoyaki-events";
in

{
  imports = [
    self.nixosModules.dynamicdns
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  sec."caddy/nanoyaki-events/environment" = {
    owner = "nanoyaki-events";
    path = "${home}/.env";
  };

  services.caddy = {
    enable = true;
    logFormat = ''
      format console
      level INFO
    '';

    virtualHosts."events.nanoyaki.space".extraConfig = ''
      root * ${home}/public

      encode zstd gzip
      file_server

      php_fastcgi unix${config.services.phpfpm.pools.nanoyaki-events.socket} {
        root ${home}/public

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

  home-manager.users.nanoyaki-events.home = {
    username = "nanoyaki-events";
    homeDirectory = home;
    stateVersion = config.system.stateVersion;

    file = {
      "public".source = "${webPkg}/public";
      "src".source = "${webPkg}/src";
      "vendor".source = "${webPkg}/vendor";
    };
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
    phpOptions = ''
      extension=${pkgs.php84Extensions.mongodb}/lib/php/extensions/mongodb.so
    '';

    settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
      "pm" = "dynamic";
      "pm.max_children" = 75;
      "pm.start_servers" = 10;
      "pm.min_spare_servers" = 5;
      "pm.max_spare_servers" = 20;
      "pm.max_requests" = 500;
      "php_flag[display_errors]" = "on";
      "php_admin_value[error_log]" = "/var/log/phpfpm.events.nanoyaki.space.log";
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

  sec."mongodb/initialScript" = { };
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-ce;
    bind_ip = "127.0.0.1";
    initialScript = config.sec."mongodb/initialScript".path;
  };
  systemd.services.mongodb.postStart =
    let
      cfg = config.services.mongodb;
    in
    ''
      if test -e "${cfg.dbpath}/.first_startup"; then
        ${lib.optionalString (cfg.initialScript != null) ''
          ${lib.getExe pkgs.mongosh} ${lib.optionalString (cfg.enableAuth) "-u root -p ${cfg.initialRootPassword}"} admin "${cfg.initialScript}"
        ''}
        rm -f "${cfg.dbpath}/.first_startup"
      fi
    '';
}
