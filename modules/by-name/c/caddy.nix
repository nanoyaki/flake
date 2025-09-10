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
  vpnV6Subnet = config.services.headscale.settings.prefixes.v6;

  sanitizeDomain = domain: builtins.replaceStrings [ "." ":" "/" ] [ "_" "-" "-" ] domain;
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
      useMtls = mkFalseOption;
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
        domain: proxy:
        nameValuePair domain {
          extraConfig = ''
            ${optionalString (proxy.userEnvVar != null) ''
              basic_auth * {
                {''$${proxy.userEnvVar}}
              }
            ''}

            ${optionalString proxy.vpnOnly ''
              @outside-local not client_ip private_ranges ${vpnV4Subnet} ${vpnV6Subnet}
              abort @outside-local
            ''}

            ${optionalString proxy.useMtls ''
              tls ${
                optionalString (
                  config.security.acme.certs ? ${cfg.baseDomain}
                ) "/var/lib/acme/${cfg.baseDomain}/cert.pem /var/lib/acme/${cfg.baseDomain}/key.pem"
              } {
                client_auth {
                  mode require_and_verify
                  trust_pool file ${config.config'.mtls.dataDir}/ca.crt
                  verifier revocation {
                    mode crl_only
                    crl_config {
                      work_dir ${config.services.caddy.dataDir}/${sanitizeDomain domain}
                      crl_file ${config.config'.mtls.dataDir}/ca.crl
                      trusted_signature_cert_file ${config.config'.mtls.dataDir}/ca.crt
                    }
                  }
                }
              }
            ''}

            ${proxy.extraConfig}

            reverse_proxy ${proxy.host}:${toString proxy.port}
          '';
          inherit (proxy) serverAliases;
        }
      ) (filterAttrs (_: hostCfg: hostCfg.enable) cfg.reverseProxies);
    };

    services.headscale.settings.dns.extra_records = mapAttrsToList (domain: _: {
      name = replaceStrings [ "http://" "https://" ] [ "" "" ] domain;
      type = "A";
      value = cfg.vpnHost;
    }) (filterAttrs (_: hostCfg: hostCfg.enable && hostCfg.vpnOnly) cfg.reverseProxies);

    systemd.services.caddy.path = [ pkgs.nssTools ];

    systemd.tmpfiles.settings.caddy-mtls = mapAttrs' (
      domain: _:
      nameValuePair "${config.services.caddy.dataDir}/${sanitizeDomain domain}" {
        d = {
          inherit (config.services.caddy) user group;
          mode = "700";
        };
      }
    ) (filterAttrs (_: hostCfg: hostCfg.enable && hostCfg.useMtls) cfg.reverseProxies);

    config'.caddy.genDomain =
      name:
      "http${optionalString cfg.useHttps "s"}://${
        optionalString (name != "") "${name}."
      }${cfg.baseDomain}";
  };
}
