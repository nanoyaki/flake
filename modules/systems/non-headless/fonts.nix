{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts-cjk-sans
      nerd-fonts.fira-code
      nerd-fonts.caskaydia-cove
      twemoji-color-font
    ];

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Noto Sans CJK JP" ];
        sansSerif = [ "Noto Sans CJK JP" ];
        monospace = [
          "FiraCode Nerd Font"
          "CaskaydiaCove Nerd Font Mono"
        ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };

  stylix.fonts = {
    serif = {
      name = "Noto Sans CJK JP";
      package = pkgs.noto-fonts-cjk-sans;
    };

    sansSerif = {
      name = "Noto Sans CJK JP";
      package = pkgs.noto-fonts-cjk-sans;
    };

    monospace = {
      name = "FiraCode Nerd Font";
      package = pkgs.nerd-fonts.fira-code;
    };

    emoji = {
      name = "Twitter Color Emoji";
      package = pkgs.twemoji-color-font;
    };

    sizes = {
      applications = 10;
      terminal = 12;
      desktop = 9;
      popups = 9;
    };
  };

  hms = [
    {
      gtk.font = {
        package = pkgs.noto-fonts-cjk-sans;
        name = "Noto Sans CJK JP";
      };
    }
  ];
}
