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
    mkRenamedOptionModule
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

  deprecatedPath = [
    "config'"
    "caddy"
    "reverseProxies"
  ];
  vHostPath = [
    "config'"
    "caddy"
    "vHost"
  ];

  mkVHostRenamedOpt =
    oldPath: newPath: mkRenamedOptionModule (deprecatedPath ++ oldPath) (vHostPath ++ newPath);

  enabledHosts = filterAttrs (_: hostCfg: hostCfg.enable) cfg.vHost;
in

{
  options.config'.caddy = {
    enable = mkFalseOption;

    openFirewall = mkFalseOption;
    useHttps = mkTrueOption;
    baseDomain = mkDefault "home.local" mkStrOption;
    email = mkDefault "hanakretzer@gmail.com" mkStrOption;
    vpnHost = mkDefault "100.64.64.1" mkStrOption;

    vHost = mkAttrsOf (mkSubmoduleOption {
      enable = mkTrueOption;
      proxy = {
        port = mkPortOption;
        host = mkDefault "localhost" mkStrOption;
      };
      userEnvVar = mkNullOr mkStrOption;
      extraConfig = mkStrOption;
      serverAliases = mkListOf mkStrOption;
      vpnOnly = mkFalseOption;
      useMtls = mkFalseOption;
    });

    genDomain = mkFunctionTo mkStrOption;
  };

  imports = [
    (mkVHostRenamedOpt [ "port" ] [ "proxy" "port" ])
    (mkVHostRenamedOpt [ "host" ] [ "proxy" "host" ])
    (mkVHostRenamedOpt [ "enable" ] [ "enable" ])
    (mkVHostRenamedOpt [ "userEnvVar" ] [ "userEnvVar" ])
    (mkVHostRenamedOpt [ "extraConfig" ] [ "extraConfig" ])
    (mkVHostRenamedOpt [ "serverAliases" ] [ "serverAliases" ])
    (mkVHostRenamedOpt [ "vpnOnly" ] [ "vpnOnly" ])
    (mkVHostRenamedOpt [ "useMtls" ] [ "useMtls" ])
  ];

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = all (domain: (hasInfix vpnDomain domain) || (hasInfix "100.64.64" domain)) (
          attrNames (filterAttrs (_: hostCfg: hostCfg.enable && hostCfg.vpnOnly) cfg.vHost)
        );
        message = "VPN only virtual hosts must use the headscale dns base domain in them";
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
        domain: vhost:
        nameValuePair domain {
          extraConfig = ''
            ${optionalString (vhost.userEnvVar != null) ''
              basic_auth * {
                {''$${vhost.userEnvVar}}
              }
            ''}

            ${optionalString vhost.vpnOnly ''
              @outside-local not client_ip private_ranges ${vpnV4Subnet} ${vpnV6Subnet}
              abort @outside-local
            ''}

            ${optionalString
              (!vhost.useMtls && config.security.acme.certs ? ${cfg.baseDomain} && hasInfix cfg.baseDomain domain)
              ''
                tls /var/lib/acme/${cfg.baseDomain}/cert.pem /var/lib/acme/${cfg.baseDomain}/key.pem
              ''
            }
            ${optionalString vhost.useMtls ''
              tls {
                client_auth {
                  mode require_and_verify
                  trust_pool file ${config.config'.mtls.dataDir}/ca.crt
                  verifier revocation {
                    mode crl_only
                    crl_config {
                      work_dir ${config.services.caddy.dataDir}/.cache/${sanitizeDomain domain}
                      crl_file ${config.config'.mtls.dataDir}/ca.crl
                      trusted_signature_cert_file ${config.config'.mtls.dataDir}/ca.crt
                    }
                  }
                }
              }
            ''}

            ${vhost.extraConfig}

            ${optionalString (vhost.proxy.port != 0) ''
              reverse_proxy ${vhost.proxy.host}:${toString vhost.proxy.port}
            ''}
          '';
          inherit (vhost) serverAliases;
        }
      ) enabledHosts;
    };

    services.headscale.settings.dns.extra_records = mapAttrsToList (domain: _: {
      name = replaceStrings [ "http://" "https://" ] [ "" "" ] domain;
      type = "A";
      value = cfg.vpnHost;
    }) (filterAttrs (_: hostCfg: hostCfg.vpnOnly) enabledHosts);

    systemd.services.caddy.path = [ pkgs.nssTools ];

    systemd.tmpfiles.settings.caddy-mtls = {
      "${config.services.caddy.dataDir}/.cache".d = {
        inherit (config.services.caddy) user group;
        mode = "750";
      };
    }
    // mapAttrs' (
      domain: _:
      nameValuePair "${config.services.caddy.dataDir}/.cache/${sanitizeDomain domain}" {
        d = {
          inherit (config.services.caddy) user group;
          mode = "700";
        };
      }
    ) (filterAttrs (_: hostCfg: hostCfg.useMtls) enabledHosts);

    config'.caddy.genDomain =
      name:
      "http${optionalString cfg.useHttps "s"}://${
        optionalString (name != "") "${name}."
      }${cfg.baseDomain}";
  };
}
