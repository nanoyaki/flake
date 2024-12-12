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
    mkHost {
      subdomain = "${user}-manga";
      config = ''
        ${mkReverseProxyConfig port}

        ${mkBasicAuthConfig user}
      '';
    };

  # attrset -> attrset
  mkHost =
    {
      domainOverride ? domain,
      subdomain ? null,
      config,
    }:

    let
      actual = if subdomain != null then "${subdomain}." else "";
    in

    {
      "${actual}${domainOverride}".extraConfig = config;
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
      (mkHost {
        subdomain = "na55l3zepb4kcg0zryqbdnay";
        config = mkFileServerConfig "/var/www/theless.one";
      })
      (mkHost {
        subdomain = "files";
        config = ''
          ${mkFileServerConfig "/var/lib/caddy/files"}

          ${mkBasicAuthConfig "shared"}
        '';
      })

      (mkMangaHost 4555 "thelessone")
      (mkMangaHost 4556 "nik")
      (mkMangaHost 4557 "hana")

      (mkHost {
        subdomain = "woodpecker";
        config = mkReverseProxyConfig 3007;
      })
      (mkHost {
        subdomain = "git";
        config = mkReverseProxyConfig 12500;
      })
      (mkHost {
        domainOverride = "nanoyaki.space";
        subdomain = "git";
        config = mkReverseProxyConfig 12500;
      })

      # (mkHost "map" (mkReverseProxyConfig 8100))
      (mkHost {
        subdomain = "metrics";
        config = ''
          ${mkReverseProxyConfig 9090}

          ${mkBasicAuthConfig "hana"}
        '';
      })
    ];
  };
}
