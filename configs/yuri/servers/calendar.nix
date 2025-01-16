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

  services.caddy = {
    enable = true;

    virtualHosts."events.nanoyaki.space".extraConfig = ''
      root * ${home}/public
      file_server
      php_fastcgi unix/${config.services.phpfpm.pools.nanoyaki-events.socket}

      @dotfiles {
        not path /.well-known/*
        path /.*
      }
      redir @dotfiles /
    '';
  };
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
    group = "nanoyaki-events";
    mode = "440";
    path = "${home}/.env";
  };

  services.phpfpm.pools.nanoyaki-events = {
    user = "nanoyaki-events";
    group = "nanoyaki-events";
    phpPackage = pkgs.php84.withExtensions ({ enabled, all }: enabled ++ [ all.mongodb ]);
    settings = {
      "listen.owner" = config.services.caddy.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "pm.max_requests" = 500;
    };
    phpEnv.PATH = lib.makeBinPath [ config.services.phpfpm.pools.nanoyaki-events.phpPackage ];
    phpOptions = ''
      extension=${pkgs.php84Extensions.mongodb}/lib/php/extensions/mongodb.so
    '';
  };

  users.groups.nanoyaki-events = { };
  users.users.nanoyaki-events = {
    isSystemUser = true;
    createHome = true;
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
