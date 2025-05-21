{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkIf
    replaceStrings
    ;
  inherit (lib') mkEnabledOption;

  inherit (lib.lists) all;
  inherit (lib.strings) hasInfix optionalString;
  inherit (lib.attrsets)
    attrNames
    filterAttrs
    mapAttrsToList
    nameValuePair
    mapAttrs'
    ;

  cfg = config.services.caddy-easify;

  vpnDomain = config.services.headscale.settings.dns.base_domain;
  vpnV4Subnet = config.services.headscale.settings.prefixes.v4;
  vpnV6Subnet = config.services.headscale.settings.prefixes.v4;
in

{
  options.services.caddy-easify = {
    enable = mkEnabledOption "caddy";

    useHttps = mkEnabledOption "https";

    baseDomain = mkOption {
      type = types.str;
      default = "home.local";
    };

    email = mkOption {
      type = types.str;
      default = "hanakretzer@gmail.com";
    };

    openFirewall = mkEnabledOption "opening the firewall for http(s) ports";

    reverseProxies = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnabledOption "this reverse proxy";

            port = mkOption { type = types.port; };

            host = mkOption {
              type = types.str;
              default = "localhost";
            };

            userEnvVar = mkOption {
              type = types.nullOr types.str;
              default = null;
            };

            extraConfig = mkOption {
              type = types.str;
              default = "";
            };

            serverAliases = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };

            vpnOnly = mkOption {
              type = types.bool;
              default = false;
            };
          };
        }
      );
      default = { };
    };

    vpnHost = mkOption {
      type = types.str;
      default = "100.64.64.1";
    };
  };

  config = mkIf cfg.enable {
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
}
