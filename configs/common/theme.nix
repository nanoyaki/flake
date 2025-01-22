{
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs.owned-material) images;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  patchedBase16 = pkgs.base16-schemes.overrideAttrs {
    patches = [ ./patches/pink-accent-mocha.patch ];
  };
in

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.catppuccin.nixosModules.catppuccin
  ];

  home-manager.sharedModules = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  stylix = {
    enable = true;

    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 32;
    };

    base16Scheme = "${patchedBase16}/share/themes/catppuccin-${catppuccin.flavor}.yaml";
    polarity = "dark";

    image = images.szcb911."2024-10-15.jpeg";

    fonts = {
      serif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts-cjk-sans;
      };

      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts-cjk-sans;
      };

      monospace = {
        name = "Cascadia Mono";
        package = pkgs.cascadia-code;
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
  };

  hm.catppuccin.gtk.icon = catppuccin;
}
