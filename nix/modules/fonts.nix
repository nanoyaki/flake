{
  flake.nixosModules.fonts =
    { pkgs, ... }:

    {
      fonts.fontconfig = {
        antialias = true;
        defaultFonts = {
          serif = [
            "Noto Sans"
            "Noto Sans CJK JP"
            "Twitter Color Emoji"
          ];
          sansSerif = [
            "Noto Sans"
            "Noto Sans CJK JP"
            "Twitter Color Emoji"
          ];
          monospace = [
            "FiraCode Nerd Font"
            "Twitter Color Emoji"
          ];
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
