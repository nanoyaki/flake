{
  lib,
  lib',
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkForce;
  inherit (lib'.options)
    mkDefault
    mkStrOption
    mkPathOption
    mkFalseOption
    ;

  inherit (config.config'.lab-config) arr;

  cfg = config.config'.transmission;
  domain = config.config'.caddy.genDomain cfg.subdomain;
in

{
  options.config'.transmission = {
    enable = mkFalseOption;

    completeDirectory = mkDefault "${arr.home}/downloads/transmission/complete" mkPathOption;
    incompleteDirectory = mkDefault "${arr.home}/downloads/transmission/incomplete" mkPathOption;

    subdomain = mkDefault "transmission" mkStrOption;
    homepage = {
      category = mkDefault "Services" mkStrOption;
      description = mkDefault "Torrent client" mkStrOption;
    };
  };

  config = mkIf cfg.enable {
    config'.vopono.services.transmission = config.services.transmission.settings.rpc-port;

    services.transmission = {
      enable = true;
      inherit (arr) group;

      package = pkgs.transmission_4;
      webHome = pkgs.flood-for-transmission;

      extraFlags = [ "-a *.*.*.*" ];

      downloadDirPermissions = "770";
      settings = {
        download-dir = cfg.completeDirectory;
        incomplete-dir = cfg.incompleteDirectory;
        incomplete-dir-enabled = true;
        rpc-port = 9091;
        rpc-bind-address = config.config'.vopono.host;
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

    # Due to *very long* startup times
    systemd.services.transmission.serviceConfig.Type = mkForce "simple";

    config'.caddy.vHost.${domain}.proxy = {
      inherit (config.config'.vopono) host;
      port = config.services.transmission.settings.rpc-port;
    };

    config'.homepage.categories.${cfg.homepage.category}.services.Transmission = {
      icon = "transmission.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };
  };
}
