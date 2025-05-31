{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts-cjk-sans
      nerd-fonts.caskaydia-cove
      twemoji-color-font
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Noto Sans CJK JP" ];
        sansSerif = [ "Noto Sans CJK JP" ];
        monospace = [ "CaskaydiaCove Nerd Font Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
