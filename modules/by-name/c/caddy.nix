{
  lib,
  lib',
  config,
  pkgs,
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
    mkFunctionTo
    ;

  inherit (lib)
    mkIf
    replaceStrings
    ;
  inherit (lib.strings) optionalString hasInfix;
  inherit (lib.lists) all;
  inherit (lib.attrsets)
    attrNames
    filterAttrs
    mapAttrsToList
    nameValuePair
    mapAttrs'
    ;

  cfg = config.config'.caddy;

  vpnDomain = config.services.headscale.settings.dns.base_domain;
  vpnV4Subnet = config.services.headscale.settings.prefixes.v4;
  vpnV6Subnet = config.services.headscale.settings.prefixes.v4;
in

{
  options.config'.caddy = {
    enable = mkFalseOption;

    openFirewall = mkFalseOption;
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

    genDomain = mkFunctionTo mkStrOption;
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = all (domain: (hasInfix vpnDomain domain) || (hasInfix "100.64.64" domain)) (
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

      globalConfig = mkIf (!cfg.useHttps) ''
        auto_https disable_redirects
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
              abort @outside-local
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

    config'.caddy.genDomain =
      name: "http${optionalString cfg.useHttps "s"}://${name}.${cfg.baseDomain}";
  };
}
