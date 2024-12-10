{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      cascadia-code
      noto-fonts
      noto-fonts-cjk-sans
      mplus-outline-fonts.githubRelease
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "M PLUS 2" ];
        sansSerif = [ "M PLUS 2" ];
        monospace = [ "Cascadia Mono" ];
      };
    };
  };
}
