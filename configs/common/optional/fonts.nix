{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts-cjk-sans
      cascadia-code
      twemoji-color-font
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Noto Sans" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Cascadia Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
