{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optionalString
    ;

  inherit (lib') mkEnabledOption toUppercase;

  service = "transmission";

  cfg = config.services.media-easify.services.${service};

  subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
  slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
  inherit (config.services.caddy-easify) baseDomain;
  scheme = "http${optionalString config.services.caddy-easify.useHttps "s"}://";

  domain = "${scheme}${subdomain}${baseDomain}${slug}";

  dirCfg = {
    inherit (config.services.transmission) user;
    inherit (config.services.media-easify) group;
    mode = "2770";
  };

  inherit (config.services.media-easify) arrHome;
in

{
  options.services.media-easify.services.${service} = {
    enable = mkEnabledOption service;

    useSubdomain = mkEnabledOption "a subdomain for ${service}";

    subdomain = mkOption {
      type = types.str;
      default = service;
    };

    useDomainSlug = mkEnableOption "the domain slug for ${service}";

    domainSlug = mkOption {
      type = types.str;
      default = service;
    };

    openFirewall = mkEnabledOption "opening the firewall for ${service}";

    homepage = {
      category = mkOption {
        type = types.str;
        default = "Services";
      };

      description = mkOption {
        type = types.str;
        default = "Torrent client";
      };
    };
  };

  config = mkIf cfg.enable {
    services.vopono.services.${service} = config.services.${service}.settings.rpc-port;

    services.${service} = {
      enable = true;
      inherit (config.services.media-easify) group;
      inherit (cfg) openFirewall;

      package = pkgs.transmission_4;
      webHome = pkgs.flood-for-transmission;

      extraFlags = [ "-a *.*.*.*" ];

      downloadDirPermissions = "770";
      settings = {
        download-dir = "${arrHome}/downloads/transmission/complete";
        incomplete-dir = "${arrHome}/downloads/transmission/incomplete";
        incomplete-dir-enabled = true;
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

    services.caddy-easify.reverseProxies.${domain} = {
      port = config.services.${service}.settings.rpc-port;
      host = "10.200.1.2";
    };

    services.homepage-easify.categories.${cfg.homepage.category}.services.${toUppercase service} = {
      icon = "${service}.svg";
      href = domain;
      siteMonitor = domain;
      inherit (cfg.homepage) description;
    };

    systemd.tmpfiles.settings."10-${service}" = {
      "${arrHome}/downloads/transmission".d = dirCfg;
      "${arrHome}/downloads/transmission/complete".d = dirCfg;
      "${arrHome}/downloads/transmission/incomplete".d = dirCfg;
    };
  };
}
