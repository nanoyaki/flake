{
  lib,
  pkgs,
  config,
  inputs',
  self,
  ...
}:

let
  inherit (inputs') discord-events-to-ics;

  eventsPkg = "${discord-events-to-ics.packages.default}/share/php/discord-events-to-ics";
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

  sec."caddy/nanoyaki-events/environment".owner = config.services.caddy.user;
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

      php_fastcgi unix/${config.services.phpfpm.pools.nanoyaki-events.socket} {
        import ${config.sec."caddy/nanoyaki-events/environment".path}
      }

      @dotfiles {
        not path /.well-known/*
        path /.*
      }
      redir @dotfiles /
    '';
  };

  home-manager.users.nanoyaki-events.home = {
    username = "nanoyaki-events";
    homeDirectory = home;
    stateVersion = config.system.stateVersion;

    file = {
      "${home}/public".source = "${eventsPkg}/public";
      "${home}/src".source = "${eventsPkg}/src";
      "${home}/vendor".source = "${eventsPkg}/vendor";
    };
  };

  services.phpfpm.pools.nanoyaki-events = {
    user = "nanoyaki-events";

    phpPackage = pkgs.php84;
    phpOptions = ''
      extension=${pkgs.php84Extensions.mongodb}/lib/php/extensions/mongodb.so
    '';

    settings = {
      "listen.owner" = config.services.caddy.user;
      "pm" = "dynamic";
      "pm.max_children" = 75;
      "pm.start_servers" = 10;
      "pm.min_spare_servers" = 5;
      "pm.max_spare_servers" = 20;
      "pm.max_requests" = 500;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
  };

  users.groups.nanoyaki-events = { };
  users.users.nanoyaki-events = {
    isSystemUser = true;
    inherit home;
    homeMode = "775";
    group = "nanoyaki-events";
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
