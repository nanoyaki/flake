{ pkgs, config, ... }:

{
  services.caddy = {
    enable = true;
    email = "hanakretzer@gmail.com";

    logFormat = ''
      format console
      level INFO
    '';

    virtualHosts = {
      "http://home.lan".extraConfig = ''
        reverse_proxy localhost:${config.services.homepage-dashboard.listenPort}
      '';

      "http://homeassistant.home.lan".extraConfig = ''
        reverse_proxy localhost:${config.services.home-assistant.config.http.server_port}
      '';

      "http://paperless.home.lan".extraConfig = ''
        reverse_proxy localhost:${config.services.paperless.port}
      '';
    };
  };

  systemd.services.caddy.path = [ pkgs.nssTools ];
}
