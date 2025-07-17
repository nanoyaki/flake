{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    ;
in

lib'.modules.mkModule {
  name = "transmission";

  options =
    { cfg', ... }:

    let
      inherit (cfg'.lab-config.arr) home;
    in

    {
      completeDirectory = mkDefault "${home}/downloads/transmission/complete" mkPathOption;
      incompleteDirectory = mkDefault "${home}/downloads/transmission/incomplete" mkPathOption;

      homepage = {
        category = mkDefault "Services" mkStrOption;
        description = mkDefault "Torrent client" mkStrOption;
      };
    };

  config =
    {
      cfg,
      cfg',
      config,
      pkgs,
      helpers',
      ...
    }:

    let
      domain = helpers'.caddy.domain cfg;
    in

    {
      services'.vopono.services.transmission = config.services.transmission.settings.rpc-port;

      services.transmission = {
        enable = true;
        inherit (cfg'.lab-config.arr) group;
        inherit (cfg) openFirewall;

        package = pkgs.transmission_4;
        webHome = pkgs.flood-for-transmission;

        extraFlags = [ "-a *.*.*.*" ];

        downloadDirPermissions = "770";
        settings = {
          download-dir = cfg.completeDirectory;
          incomplete-dir = cfg.incompleteDirectory;
          incomplete-dir-enabled = true;
          rpc-port = helpers'.firewall.defaultPort cfg 9091;
          rpc-bind-address = "10.200.1.2";
          rpc-whitelist = "*.*.*.*";
          rpc-url = "/";
          rpc-host-whitelist = "*";
          rpc-host-whitelist-enabled = true;
          ratio-limit = 1;
          ratio-limit-enabled = true;

          blocklist-enabled = true;
          blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/refs/heads/master/bt_blocklists.gz";

          speed-limit-down-enabled = lib.mkDefault true;
          speed-limit-down = lib.mkDefault 10000;
          speed-limit-up-enabled = lib.mkDefault true;
          speed-limit-up = lib.mkDefault 2500;
        };
      };

      systemd.services.transmission.serviceConfig.Type = lib.mkForce "simple";

      services'.caddy.reverseProxies.${domain} = {
        host = "10.200.1.2";
        port = config.services.transmission.settings.rpc-port;
      };

      services'.homepage.categories.${cfg.homepage.category}.services.Transmission = {
        icon = "transmission.svg";
        href = domain;
        siteMonitor = domain;
        inherit (cfg.homepage) description;
      };
    };

  dependencies = [
    "firewall"
    "caddy"
    "homepage"
    "lab-config"
  ];
}
