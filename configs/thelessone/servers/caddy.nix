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
    ${mkReverseProxyConfig port}

    ${mkBasicAuthConfig user}
  '';

  # Int -> String
  mkReverseProxyConfig = port: ''
    reverse_proxy localhost:${toString port}
  '';

  # String -> String
  mkBasicAuthConfig = user: ''
    basic_auth * {
      import ${config.sec."caddy/users/${user}".path}
    }
  '';

  # String -> String
  mkFileServerConfig = directory: ''
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

  services.caddy = {
    enable = true;

    virtualHosts = {
      "na55l3zepb4kcg0zryqbdnay.theless.one".extraConfig = mkFileServerConfig "/var/www/theless.one";
      "files.theless.one".extraConfig = ''
        ${mkFileServerConfig "/var/lib/caddy/files"}

        ${mkBasicAuthConfig "shared"}
      '';
      "files.nanoyaki.space".extraConfig = ''
        ${mkFileServerConfig "/var/lib/caddy/nanoyaki-files"}

        ${mkBasicAuthConfig "hana"}
      '';

      "manga.theless.one".extraConfig = mkProtectedHost 4555 "thelessone";
      "nik-manga.theless.one".extraConfig = mkProtectedHost 4556 "nik";
      "hana-manga.theless.one".extraConfig = mkProtectedHost 4557 "hana";

      "git.theless.one".extraConfig = mkReverseProxyConfig 12500;
      "git.nanoyaki.space".extraConfig = mkReverseProxyConfig 12500;
      "woodpecker.theless.one".extraConfig = mkReverseProxyConfig 3007;

      # "map.theless.one".extraConfig = mkReverseProxyConfig 8100;
      "metrics.theless.one".extraConfig = mkProtectedHost 9090 "hana";
    };
  };

  systemd.tmpfiles.settings = {
    "10-na55l3zepb4kcg0zryqbdnay.theless.one"."/var/www/theless.one".d = dirConfig;
    "10-files.theless.one"."/var/lib/caddy/files".d = dirConfig;
    "10-files.nanoyaki.space"."/var/lib/caddy/nanoyaki-files".d = dirConfig;
  };
}
