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
      name = "CaskaydiaCove Nerd Font Mono";
      package = pkgs.nerd-fonts.caskaydia-cove;
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
