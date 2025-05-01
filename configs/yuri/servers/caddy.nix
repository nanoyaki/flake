{ pkgs, config, ... }:

let
  mkReverseProxy = port: ''
    reverse_proxy localhost:${toString port}
  '';
in

{
  services.caddy = {
    enable = true;
    email = "hanakretzer@gmail.com";

    logFormat = ''
      format console
      level INFO
    '';

    globalConfig = ''
      auto_https disable_redirects
    '';

    virtualHosts = {
      "http://home.local".extraConfig = mkReverseProxy config.services.homepage-dashboard.listenPort;

      "http://homeassistant.home.local".extraConfig =
        mkReverseProxy config.services.home-assistant.config.http.server_port;

      "http://paperless.home.local".extraConfig = mkReverseProxy config.services.paperless.port;
    };
  };

  systemd.services.caddy.path = [ pkgs.nssTools ];
}
