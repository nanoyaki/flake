{
  lib,
  config,
  ...
}:

let
  inherit (lib) genAttrs;

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
in

{
  sec."caddy/users".owner = config.services.caddy.user;

  services.caddy = {
    environmentFile = config.sec."caddy/users".path;

    virtualHosts = {
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

  services'.caddy.reverseProxies."https://coolercontrol.nas.vpn.theless.one" = {
    port = 11987;
    host = "192.168.178.91";
    vpnOnly = true;
  };

  systemd.tmpfiles.settings."10-caddy-directories" =
    genAttrs
      [
        "/var/www/theless.one"
        "/var/lib/caddy/files"
        "/var/lib/caddy/nanoyaki-files"
      ]
      (_: {
        d = {
          inherit (config.services.caddy) group user;
          mode = "2770";
        };
      });
}
