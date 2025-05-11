{
  config,
  ...
}:

let
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

  systemd.tmpfiles.settings = {
    "10-na55l3zepb4kcg0zryqbdnay.theless.one"."/var/www/theless.one".d = dirConfig;
    "10-files.theless.one"."/var/lib/caddy/files".d = dirConfig;
    "10-files.nanoyaki.space"."/var/lib/caddy/nanoyaki-files".d = dirConfig;
  };
}
