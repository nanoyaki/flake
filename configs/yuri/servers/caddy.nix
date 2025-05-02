{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) types mkOption;

  cfg = config.services.caddy-easify;

  mkReverseProxy = port: ''
    reverse_proxy localhost:${toString port}
  '';
in

{
  options.services.caddy-easify.reverseProxies = mkOption {
    type = types.attrsOf (types.submodule { options.port = mkOption { type = types.port; }; });
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
        extraConfig = mkReverseProxy reverseProxy.port;
      }) cfg.reverseProxies;
    };

    systemd.services.caddy.path = [ pkgs.nssTools ];
  };
}
