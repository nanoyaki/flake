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

    programs.plasma.shortcuts."rofi.desktop"._launch = "Meta+S";
    xdg.desktopEntries.rofi = {
      name = "Rofi";
      exec = "${lib.getExe config.hm.programs.rofi.finalPackage} -show drun";
      icon = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/apps/nix-snowflake.svg";
      type = "Application";
    };
  };
}
