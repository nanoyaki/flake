{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib) types mkOption mkIf;
  inherit (lib') mkEnabledOption;

  cfg = config.services.caddy-easify;
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
          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
      80
      (mkIf cfg.useHttps 443)
    ];

    services.caddy = {
      enable = true;
      inherit (cfg) email;

      logFormat = ''
        format console
        level INFO
      '';

      virtualHosts = lib.mapAttrs (_: reverseProxy: {
        extraConfig = ''
          ${lib.optionalString (reverseProxy.userEnvVar != null) ''
            basic_auth * {
              {''$${reverseProxy.userEnvVar}}
            }
          ''}

          ${reverseProxy.extraConfig}

          reverse_proxy ${reverseProxy.host}:${toString reverseProxy.port}
        '';
        inherit (reverseProxy) serverAliases;
      }) cfg.reverseProxies;
    };

    systemd.services.caddy.path = [ pkgs.nssTools ];
  };
}
