{
  flake.nixosModules.fonts =
    { pkgs, ... }:

    {
      fonts.fontconfig = {
        antialias = true;
        useEmbeddedBitmaps = true;
        defaultFonts = {
          serif = [
            "Noto Sans"
            "Noto Sans CJK JP"
          ];
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK JP"
          ];
          monospace = [ "FiraCode Nerd Font" ];
          emoji = [ "Twitter Color Emoji" ];
        };
      };

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        nerd-fonts.fira-code
        twemoji-color-font
      ];
    };
}
