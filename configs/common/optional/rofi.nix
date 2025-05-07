{
  lib,
  pkgs,
  config,
  ...
}:

{
  hm = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      location = "center";
      terminal = lib.getExe pkgs.alacritty;
    };

    home.packages = [ pkgs.rofi-power-menu ];

    programs.plasma.shortcuts."rofi-run.desktop"._launch = "Meta+S";

    xdg.dataFile."applications/rofi-run.desktop".source = "${
      pkgs.makeDesktopItem rec {
        name = "rofi";
        desktopName = "Rofi";
        genericName = comment;
        comment = "Application launcher";
        exec = "${lib.getExe config.hm.programs.rofi.finalPackage} -show drun";
        icon = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/apps/nix-snowflake.svg";
        startupNotify = true;
        startupWMClass = "rofi";
        terminal = false;
        categories = [
          "Utility"
          "System"
        ];
      }
    }/share/applications/rofi.desktop";
  };
}
