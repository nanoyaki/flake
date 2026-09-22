{ config, ... }:

{
  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.mpv ];
  };

  modules.home.mpv =
    { pkgs, ... }:

    {
      programs.mpv = {
        enable = true;

        config = {
          osc = "no";
          volume = 40;
        };

        scripts = with pkgs.mpvScripts; [
          sponsorblock
          thumbfast
          modernx
          mpv-discord
          mpv-subtitle-lines
          mpv-playlistmanager
          mpv-cheatsheet-ng
        ];
      };
    };

  modules.home.xdg =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.mpv.enable {
        xdg.mimeApps.defaultApplications = {
          "audio/*" = "mpv.desktop";
          "video/*" = "mpv.desktop";
        };
      };
    };
}
