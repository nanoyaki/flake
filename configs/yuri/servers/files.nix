let
  directory = "/mnt/shares/Videos";
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

  services.samba.settings.videos = {
    path = directory;
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0660";
    "directory mask" = "0770";
    "force user" = "hana";
    "force group" = "hana";
    "valid users" = "hana";
  };

  services.namecheapDynDns.domains."nanoyaki.space".subdomains = [ "videos" ];
}
