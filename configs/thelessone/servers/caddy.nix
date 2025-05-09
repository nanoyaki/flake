{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) types mkOption;

  cfg = config.services.caddy-easify;

  # String -> String
  mkBasicAuth = user: ''
    basic_auth * {
      {''$${user}}
    }
  '';

  # String -> String
  mkFileServer = directory: ''
    root * ${directory}
    file_server * browse
  '';

  mkRedirect = url: ''
    redir ${url} permanent
  '';

  dirConfig = {
    inherit (config.services.caddy) group user;
    mode = "0700";
  };
in

{
  options.services.caddy-easify.reverseProxies = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          port = mkOption { type = types.port; };

          host = mkOption {
            type = types.nullOr types.str;
            default = null;
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

  config = {
    sec."caddy/users".owner = config.services.caddy.user;

    services.caddy = {
      enable = true;
      email = "hanakretzer@gmail.com";

      logFormat = ''
        format console
        level INFO
      '';

      environmentFile = config.sec."caddy/users".path;

      virtualHosts =
        (lib.mapAttrs (
          _: reverseProxy:
          let
            host = if reverseProxy.host != null then reverseProxy.host else "localhost";
          in
          {
            extraConfig = ''
              ${lib.optionalString (reverseProxy.userEnvVar != null) ''
                basic_auth * {
                  {''$${reverseProxy.userEnvVar}}
                }
              ''}

              reverse_proxy ${host}:${toString reverseProxy.port}
              ${reverseProxy.extraConfig}
            '';
            inherit (reverseProxy) serverAliases;
          }
        ) cfg.reverseProxies)
        // {
          "na55l3zepb4kcg0zryqbdnay.theless.one".extraConfig = mkFileServer "/var/www/theless.one";
          "files.theless.one".extraConfig = ''
            ${mkFileServer "/var/lib/caddy/files"}

            ${mkBasicAuth "shared"}
          '';

          "nanoyaki.space".extraConfig = mkRedirect "https://bsky.app/profile/nanoyaki.space";
          "www.nanoyaki.space".extraConfig = mkRedirect "https://bsky.app/profile/nanoyaki.space";
          "twitter.nanoyaki.space".extraConfig = mkRedirect "https://x.com/nanoyaki";
          "files.nanoyaki.space".extraConfig = ''
            ${mkFileServer "/var/lib/caddy/nanoyaki-files"}

            ${mkBasicAuth "hana"}
          '';

          "vappie.space".extraConfig = mkRedirect "https://bsky.app/profile/vappie.space";
          "www.vappie.space".extraConfig = mkRedirect "https://bsky.app/profile/vappie.space";
          "twitter.vappie.space".extraConfig = mkRedirect "https://x.com/vappie_";
        };
    };

    systemd.services.caddy.path = [ pkgs.nssTools ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    systemd.tmpfiles.settings = {
      "10-na55l3zepb4kcg0zryqbdnay.theless.one"."/var/www/theless.one".d = dirConfig;
      "10-files.theless.one"."/var/lib/caddy/files".d = dirConfig;
      "10-files.nanoyaki.space"."/var/lib/caddy/nanoyaki-files".d = dirConfig;
    };
  };
}
