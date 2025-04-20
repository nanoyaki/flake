{ pkgs, ... }:

{
  hm = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };

    home.packages = [ pkgs.rofi-power-menu ];
  };
}
