{ config, ... }:

{
  hm.xdg.userDirs =
    let
      homeDir = config.hm.home.homeDirectory;
    in
    {
      enable = true;

      desktop = "${homeDir}/Schreibtisch";
      download = "${homeDir}/Downloads";
      documents = "${homeDir}/Dokumente";

      videos = null;
      pictures = null;
      publicShare = null;
      templates = null;
      music = null;
    };
}
