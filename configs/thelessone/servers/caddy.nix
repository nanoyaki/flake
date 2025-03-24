{ lib, config, ... }:

let
  inherit (lib) nameValuePair;
  cfg = config.services.caddy;

  # [ String ] -> attrset
  mapSecretsOwner =
    users:
    builtins.listToAttrs (
      builtins.map (authUser: nameValuePair "caddy/users/${authUser}" { owner = cfg.user; }) users
    );

  # Int -> String -> String
  mkProtectedHost = port: user: ''
    ${mkReverseProxy port}

    ${mkBasicAuth user}
  '';

  # Int -> String
  mkReverseProxy = port: ''
    reverse_proxy localhost:${toString port}
  '';

  # String -> String
  mkBasicAuth = user: ''
    basic_auth * {
      import ${config.sec."caddy/users/${user}".path}
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
    inherit (cfg) group user;
    mode = "0700";
  };
in

{
  sec = mapSecretsOwner [
    "shared"
    "thelessone"
    "nik"
    "hana"
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;
    logFormat = ''
      format console
      level INFO
    '';

    virtualHosts =
      (
        let
          self = "theless.one";
        in
        {
          "na55l3zepb4kcg0zryqbdnay.${self}".extraConfig = mkFileServer "/var/www/${self}";
          "files.${self}".extraConfig = ''
            ${mkFileServer "/var/lib/caddy/files"}

            ${mkBasicAuth "shared"}
          '';

          "manga.${self}".extraConfig = mkProtectedHost 4555 "thelessone";
          "nik-manga.${self}".extraConfig = mkProtectedHost 4556 "nik";
          "hana-manga.${self}".extraConfig = mkProtectedHost 4557 "hana";

          "git.${self}".extraConfig = mkReverseProxy 12500;
          "woodpecker.${self}".extraConfig = mkReverseProxy 3007;

          "map.theless.one".extraConfig = mkReverseProxy 8100;
          "metrics.${self}".extraConfig = mkProtectedHost 9090 "hana";
          "jellyfin.${self}".extraConfig = mkReverseProxy 8096;
        }
      )
      // (
        let
          self = "nanoyaki.space";
        in
        {
          ${self}.extraConfig = mkRedirect "https://bsky.app/profile/${self}";
          "www.${self}".extraConfig = mkRedirect "https://bsky.app/profile/${self}";
          "twitter.${self}".extraConfig = mkRedirect "https://x.com/nanoyaki";

          "files.${self}".extraConfig = ''
            ${mkFileServer "/var/lib/caddy/nanoyaki-files"}

            ${mkBasicAuth "hana"}
          '';

          "git.${self}".extraConfig = mkReverseProxy 12500;
          "immich.${self}".extraConfig = mkReverseProxy 2283;
        }
      )
      // (
        let
          self = "vappie.space";
        in
        {
          ${self}.extraConfig = mkRedirect "https://bsky.app/profile/${self}";
          "www.${self}".extraConfig = mkRedirect "https://bsky.app/profile/${self}";
          "twitter.${self}".extraConfig = mkRedirect "https://x.com/vappie_";
        }
      );
  };

  systemd.tmpfiles.settings = {
    "10-na55l3zepb4kcg0zryqbdnay.theless.one"."/var/www/theless.one".d = dirConfig;
    "10-files.theless.one"."/var/lib/caddy/files".d = dirConfig;
    "10-files.nanoyaki.space"."/var/lib/caddy/nanoyaki-files".d = dirConfig;
  };
}
