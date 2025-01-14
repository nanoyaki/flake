{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:

let
  inherit (inputs') discord-events-to-ics;

  eventsPkg = "${discord-events-to-ics.packages.default}/share/php/discord-events-to-ics";
  home = "/var/lib/caddy/nanoyaki-events";
in

{
  services.caddy.virtualHosts."events.austria.nanoyaki.space".extraConfig = ''
    root * /var/lib/caddy/nanoyaki-events/public
    file_server
    php_fastcgi unix/${config.services.phpfpm.pools.nanoyaki-events.socket}

    @dotfiles {
      not path /.well-known/*
      path /.*
    }
    redir @dotfiles /
  '';
  users.users.caddy.extraGroups = [ "nanoyaki-events" ];

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

  sec."caddy/nanoyaki-events/environment" = {
    owner = "nanoyaki-events";
    path = "${home}/.env";
  };

  services.phpfpm.pools.nanoyaki-events = {
    user = "nanoyaki-events";
    group = "nanoyaki-events";
    phpPackage = pkgs.php84;
    settings = {
      "listen.owner" = config.services.caddy.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "pm.max_requests" = 500;
    };
    phpEnv.PATH = lib.makeBinPath [ pkgs.php84 ];
    phpOptions = ''
      extension=${pkgs.php84Extensions.mongodb}/lib/php/extensions/mongodb.so
    '';
  };

  users.groups.nanoyaki-events = { };
  users.users.nanoyaki-events = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/caddy/nanoyaki-events";
    homeMode = "750";
    group = "nanoyaki-events";
  };
}
