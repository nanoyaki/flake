{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) genAttrs;

  # String -> String
  # mkBasicAuth = user: ''
  #   basic_auth * {
  #     {''$${user}}
  #   }
  # '';

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
  sops.secrets = {
    "caddy-env-vars/nik" = { };
    "caddy-env-vars/hana" = { };
    "caddy-env-vars/shared" = { };
    "caddy-env-vars/thelessone" = { };
  };

  sops.templates."caddy-users.env".file = (pkgs.formats.keyValue { }).generate "caddy-users.env" {
    nik = "nik ${config.sops.placeholder."caddy-env-vars/nik"}";
    hana = "hana ${config.sops.placeholder."caddy-env-vars/hana"}";
    shared = "user ${config.sops.placeholder."caddy-env-vars/shared"}";
    thelessone = "thelessone ${config.sops.placeholder."caddy-env-vars/thelessone"}";
  };

  config'.caddy.enable = true;
  config'.caddy.openFirewall = true;
  services.caddy = {
    enable = true;
    environmentFile = config.sops.templates."caddy-users.env".path;

    virtualHosts = {
      "na55l3zepb4kcg0zryqbdnay.theless.one".extraConfig = mkFileServer "/var/www/theless.one";
      "files.theless.one".extraConfig = mkFileServer "/var/lib/caddy/files";

      "vappie.space".extraConfig = mkRedirect "https://bsky.app/profile/vappie.space";
      "www.vappie.space".extraConfig = mkRedirect "https://bsky.app/profile/vappie.space";
      "twitter.vappie.space".extraConfig = mkRedirect "https://x.com/vappie_";
    };
  };

  config'.caddy.reverseProxies."http://100.64.64.1:8123" = {
    port = 8000;
    host = "10.0.0.6";
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
