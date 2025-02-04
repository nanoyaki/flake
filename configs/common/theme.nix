{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  midnight-theme = pkgs.fetchFromGitHub {
    owner = "refact0r";
    repo = "midnight-discord";
    rev = "ddb8a946c526a64523563fde0dc208ce60734790";
    hash = "sha256-dufz6GPTLux9df2AQMI4TxGCHvsWSKDMvK3VBXVOOWU=";
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

  catppuccin = {
    inherit (catppuccin) enable flavor accent;

    sddm.background = "${config.stylix.image}";
  };

  stylix = {
    enable = true;
    autoEnable = false;

    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 32;
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${catppuccin.flavor}.yaml";
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

  environment.systemPackages = [
    (pkgs.catppuccin-papirus-folders.override {
      inherit (catppuccin) accent flavor;
    })

    (pkgs.catppuccin.override {
      inherit (catppuccin) accent;
      variant = catppuccin.flavor;
    })

    (lib.mkIf config.services.desktopManager.plasma6.enable (
      pkgs.catppuccin-kde.override {
        flavour = [ catppuccin.flavor ];
        accents = [ catppuccin.accent ];
      }
    ))
  ];

  hm = {
    catppuccin = {
      inherit (catppuccin) enable flavor accent;

      kvantum = {
        inherit (catppuccin) enable flavor accent;
        apply = true;
      };

      gtk.icon = catppuccin;
    };

    xdg.configFile."vesktop/themes".source = "${midnight-theme}/flavors";
  };
}
