{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib)
    genAttrs
    nameValuePair
    mapAttrs'
    filterAttrs
    ;

  excludes = [
    "uptimekuma"
    "immich"
    "vaultwarden"
    "homepage-images"
    "homepage"
  ];

  privateServices = filterAttrs (
    name: cfg: cfg ? enable && cfg.enable && !(lib.elem name excludes) && cfg ? subdomain
  ) config.config';

  # String -> String
  mkFileServer = directory: ''
    root * ${directory}
    file_server * browse
  '';

  # String -> String
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

  services.caddy = {
    enable = true;
    package = lib.mkForce (
      pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddyserver/cache-handler@v0.16.0"
          "github.com/gr33nbl00d/caddy-revocation-validator@v1.0.5"
        ];
        hash = "sha256-BxvrPs02TOIYDMJzPjzkGTVC7kDA4WJg98XLiRw9rV0=";
      }
    );
    environmentFile = config.sops.templates."caddy-users.env".path;

    virtualHosts = {
      "na55l3zepb4kcg0zryqbdnay.theless.one".extraConfig = mkFileServer "/var/www/theless.one";
      "files.theless.one".extraConfig = mkFileServer "/var/lib/caddy/files";

      "vappie.space".extraConfig = mkRedirect "https://bsky.app/profile/vappie.space";
      "www.vappie.space".extraConfig = mkRedirect "https://bsky.app/profile/vappie.space";
      "twitter.vappie.space".extraConfig = mkRedirect "https://x.com/vappie_";
    };
  };

  config'.mtls = {
    enable = true;

    clients = {
      nano = { };
      ashley = { };
      maru = { };
      nik = { };
      vapper = { };
      thomas = { };
      koko = { };
      juli = { };
      dowo = { };
      pascal = { };
    };
  };

  config'.caddy = {
    enable = true;
    openFirewall = true;
    baseDomain = "theless.one";

    reverseProxies =
      (mapAttrs' (
        service: _:
        nameValuePair (config.config'.caddy.genDomain config.config'.${service}.subdomain) {
          vpnOnly = true;
        }
      ) privateServices)
      // {
        # Restic
        "http://100.64.64.1:8123" = {
          port = 8000;
          host = "10.0.0.6";
          vpnOnly = true;
        };
      };
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
