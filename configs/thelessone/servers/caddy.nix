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

    virtualHosts = {
      "na55l3zepb4kcg0zryqbdnay.theless.one".extraConfig = mkFileServer "/var/www/theless.one";
      "files.theless.one".extraConfig = ''
        ${mkFileServer "/var/lib/caddy/files"}

        ${mkBasicAuth "shared"}
      '';
      "files.nanoyaki.space".extraConfig = ''
        ${mkFileServer "/var/lib/caddy/nanoyaki-files"}

        ${mkBasicAuth "hana"}
      '';

      "manga.theless.one".extraConfig = mkProtectedHost 4555 "thelessone";
      "nik-manga.theless.one".extraConfig = mkProtectedHost 4556 "nik";
      "hana-manga.theless.one".extraConfig = mkProtectedHost 4557 "hana";

      "git.theless.one".extraConfig = mkReverseProxy 12500;
      "git.nanoyaki.space".extraConfig = mkReverseProxy 12500;
      "woodpecker.theless.one".extraConfig = mkReverseProxy 3007;

      # "map.theless.one".extraConfig = mkReverseProxyConfig 8100;
      "metrics.theless.one".extraConfig = mkProtectedHost 9090 "hana";
      "jellyfin.theless.one".extraConfig = mkProtectedHost 8096 "shared";
    };
  };

  systemd.tmpfiles.settings = {
    "10-na55l3zepb4kcg0zryqbdnay.theless.one"."/var/www/theless.one".d = dirConfig;
    "10-files.theless.one"."/var/lib/caddy/files".d = dirConfig;
    "10-files.nanoyaki.space"."/var/lib/caddy/nanoyaki-files".d = dirConfig;
  };
}
