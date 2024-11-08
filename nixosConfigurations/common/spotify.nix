{ config, pkgs, ... }:

{
  hm = {
    home.packages = [ pkgs.spotify-qt ];

    services.spotifyd = {
      enable = true;

      settings.global = {
        username = "aex77xiuiva5s17odjzngj6jb";
        password_cmd = "cat ${config.sops.secrets."spotify/password".path}";
      };
    };
  };
}
