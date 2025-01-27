let
  directory = "/var/lib/caddy/videos";
in

{
  services.caddy.virtualHosts."videos.nanoyaki.space".extraConfig = ''
    root * ${directory}
    file_server * browse
  '';

  systemd.tmpfiles.settings."10-caddy-videos-file-server".${directory}.d = {
    user = "caddy";
    group = "caddy";
    mode = "0770";
  };

  services.namecheapDynDns.domains."nanoyaki.space".subdomains = [ "videos" ];
}
