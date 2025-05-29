{
  lib,
  lib',
  ...
}:

let
  inherit (lib'.options)
    mkDefault
    mkAttrsOf
    mkNullOr
    mkListOf
    mkTrueOption
    mkFalseOption
    mkPortOption
    mkSubmoduleOption
    mkStrOption
    ;

  inherit (lib.strings) optionalString;
in

lib'.modules.mkModule {
  name = "caddy";

  options = {
    useHttps = mkTrueOption;
    baseDomain = mkDefault "home.local" mkStrOption;
    email = mkDefault "hanakretzer@gmail.com" mkStrOption;
    vpnHost = mkDefault "100.64.64.1" mkStrOption;

    reverseProxies = mkAttrsOf (mkSubmoduleOption {
      enable = mkTrueOption;
      port = mkPortOption;
      host = mkDefault "localhost" mkStrOption;
      userEnvVar = mkNullOr mkStrOption;
      extraConfig = mkStrOption;
      serverAliases = mkListOf mkStrOption;
      vpnOnly = mkFalseOption;
    });
  };

  config =
    {
      cfg,
      config,
      pkgs,
      ...
    }:

    let
      inherit (lib)
        mkIf
        replaceStrings
        ;

      inherit (lib.lists) all;
      inherit (lib.strings) hasInfix optionalString;
      inherit (lib.attrsets)
        attrNames
        filterAttrs
        mapAttrsToList
        nameValuePair
        mapAttrs'
        ;

      vpnDomain = config.services.headscale.settings.dns.base_domain;
      vpnV4Subnet = config.services.headscale.settings.prefixes.v4;
      vpnV6Subnet = config.services.headscale.settings.prefixes.v4;
    in

    {
      assertions = [
        {
          assertion = all (domain: hasInfix vpnDomain domain) (
            attrNames (filterAttrs (_: hostCfg: hostCfg.enable && hostCfg.vpnOnly) cfg.reverseProxies)
          );
          message = "VPN only reverse proxies must use the headscale dns base domain in them";
        }
      ];

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
        80
        443
      ];

      services.caddy = {
        enable = true;
        inherit (cfg) email;

        logFormat = ''
          format console
          level INFO
        '';

        globalConfig = ''
          auto_https ${if cfg.useHttps then "disable_redirects" else "off"}
        '';

        virtualHosts = mapAttrs' (
          domain: reverseProxy:
          nameValuePair domain {
            extraConfig = ''
              ${optionalString (reverseProxy.userEnvVar != null) ''
                basic_auth * {
                  {''$${reverseProxy.userEnvVar}}
                }
              ''}

              ${optionalString reverseProxy.vpnOnly ''
                @outside-local not client_ip private_ranges ${vpnV4Subnet} ${vpnV6Subnet}
                respond @outside-local "Access Denied" 403 {
                  close
                }
              ''}

              ${reverseProxy.extraConfig}

              reverse_proxy ${reverseProxy.host}:${toString reverseProxy.port}
            '';
            inherit (reverseProxy) serverAliases;
          }
        ) (filterAttrs (_: hostCfg: hostCfg.enable) cfg.reverseProxies);
      };

      services.headscale.settings.dns.extra_records = mapAttrsToList (domain: _: {
        name = replaceStrings [ "http://" "https://" ] [ "" "" ] domain;
        type = "A";
        value = cfg.vpnHost;
      }) (filterAttrs (_: hostCfg: hostCfg.enable && hostCfg.vpnOnly) cfg.reverseProxies);

      systemd.services.caddy.path = [ pkgs.nssTools ];
    };

  sharedOptions =
    { name }:

    {
      useSubdomain = mkTrueOption;
      subdomain = mkDefault name mkStrOption;
      useDomainSlug = mkFalseOption;
      domainSlug = mkDefault name mkStrOption;
    };

  helpers =
    { cfg }:

    {
      domain =
        cfg':
        let
          scheme = "http${optionalString cfg.useHttps "s"}://";
          subdomain = optionalString cfg'.useSubdomain "${cfg'.subdomain}.";
          slug = optionalString cfg'.useDomainSlug "/${cfg'.domainSlug}";
        in
        "${scheme}${subdomain}${cfg.baseDomain}${slug}";
    };

  dependencies = [ "firewall" ];
}
