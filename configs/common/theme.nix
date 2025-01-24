{
  pkgs,
  inputs,
  ...
}:

let
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

    # revert until https://github.com/NixOS/nix/pull/10153 is merged
    image = pkgs.fetchurl {
      url = "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:n3xxlxmlutbyeih4rphvn5o3/bafkreie6qpaxgmgbelgddjezoqknolhqvhtwdpeq4ucfbup35oytb5i3ma@png";
      hash = "sha256-b9z6cs9hkaC1iC4oU5S7iYIYvfroPhepehHf3aLXFoc=";
    };

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
