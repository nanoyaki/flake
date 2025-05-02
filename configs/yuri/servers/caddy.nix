{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) types mkOption;

  cfg = config.services.caddy-easify;
in

{
  options.services.caddy-easify.reverseProxies = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          port = mkOption { type = types.port; };

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

  config = {
    services.caddy = {
      enable = true;
      email = "hanakretzer@gmail.com";

      logFormat = ''
        format console
        level INFO
      '';

      globalConfig = ''
        auto_https disable_redirects
      '';

      virtualHosts = lib.mapAttrs (_: reverseProxy: {
        extraConfig = ''
          ${lib.optionalString (reverseProxy.userEnvVar != null) ''
            basic_auth * {
              {''$${reverseProxy.userEnvVar}}
            }
          ''}

          reverse_proxy localhost:${toString reverseProxy.port}
          ${reverseProxy.extraConfig}
        '';
        inherit (reverseProxy) serverAliases;
      }) cfg.reverseProxies;
    };

    systemd.services.caddy.path = [ pkgs.nssTools ];
  };
}
