let
  directory = "/mnt/shares/Videos";
in

{
  users.groups.videos = { };
  users.users.caddy.extraGroups = [ "videos" ];
  users.users.hana.extraGroups = [ "videos" ];

  services.caddy.virtualHosts."videos.nanoyaki.space".extraConfig = ''
    root * ${directory}
    file_server * browse
  '';

  systemd.tmpfiles.settings."10-caddy-videos-file-server".${directory}.d = {
    user = "caddy";
    group = "videos";
    mode = "0770";
  };

  services.samba.settings.videos = {
    path = directory;
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0770";
    "directory mask" = "0770";
    "force user" = "caddy";
    "force group" = "videos";
    "valid users" = "hana";
  };

  services.namecheapDynDns.domains."nanoyaki.space".subdomains = [ "videos" ];
}
