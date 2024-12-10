{ lib, config, ... }:

let
  inherit (lib) mkMerge;

  domain = "theless.one";

  # [ String ] -> attrset
  mapSecretsOwner =
    users:
    mkMerge (
      builtins.map (authUser: {
        "caddy/users/${authUser}".owner = config.services.caddy.user;
      }) users
    );

  # Int -> String -> attrset
  mkMangaHost =
    port: user:
    mkHost "${user}-manga" ''
      ${mkReverseProxyConfig port}

      ${mkBasicAuthConfig user}
    '';

  # String -> String -> attrset
  mkHost =
    subdomain: config:
    let
      actual = if subdomain != null then "${subdomain}." else "";
    in
    {
      "${actual}${domain}".extraConfig = config;
    };

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

    virtualHosts = mkMerge [
      (mkHost "na55l3zepb4kcg0zryqbdnay" (mkFileServerConfig "/var/www/theless.one"))
      (mkHost "files" ''
        ${mkFileServerConfig "/var/lib/caddy/files"}

        ${mkBasicAuthConfig "shared"}
      '')

      (mkMangaHost 4555 "thelessone")
      (mkMangaHost 4556 "nik")
      (mkMangaHost 4557 "hana")

      # (mkHost "map" (mkReverseProxyConfig 8100))
      (mkHost "git" (mkReverseProxyConfig 12500))
      (mkHost "metrics" ''
        ${mkReverseProxyConfig 9090}

        ${mkBasicAuthConfig "hana"}
      '')
    ];
  };
}
