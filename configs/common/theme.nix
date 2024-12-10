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
in

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  home-manager.sharedModules = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  inherit catppuccin;

  environment.systemPackages = [
    # pkgs.catppuccin-cursors.mochaPink

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

  services.displayManager.sddm.catppuccin = {
    enable = true;
    assertQt6Sddm = true;
    flavor = "mocha";
    background = "${config.hm.xdg.userDirs.pictures}/Wallpaper/Wallpaper.png";
    loginBackground = true;
  };

  hm = {
    catppuccin = {
      inherit (catppuccin) enable flavor accent;

      # pointerCursor = {
      #   inherit (catppuccin) enable flavor accent;
      # };
    };

    # https://github.com/catppuccin/lsd/blob/92d4a10318e5dfde29dbe52d166952dbf1834a0d/themes/catppuccin-mocha/colors.yaml
    programs.lsd.colors = {
      user = "#cba6f7";
      group = "#b4befe";

      permission = {
        read = "#a6e3a1";
        write = "#f9e2af";
        exec = "#eba0ac";
        exec-sticky = "#cba6f7";
        no-access = "#a6adc8";
        octal = "#94e2d5";
        acl = "#94e2d5";
        context = "#89dceb";
      };

      date = {
        hour-old = "#94e2d5";
        day-old = "#89dceb";
        older = "#74c7ec";
      };

      size = {
        none = "#a6adc8";
        small = "#a6e3a1";
        medium = "#f9e2af";
        large = "#fab387";
      };

      inode = {
        valid = "#f5c2e7";
        invalid = "#a6adc8";
      };

      links = {
        valid = "#f5c2e7";
        invalid = "#a6adc8";
      };

      tree-edge = "#bac2de";

      git-status = {
        default = "#cdd6f4";
        unmodified = "#a6adc8";
        ignored = "#a6adc8";
        new-in-index = "#a6e3a1";
        new-in-workdir = "#a6e3a1";
        typechange = "#f9e2af";
        deleted = "#f38ba8";
        renamed = "#a6e3a1";
        modified = "#f9e2af";
        conflicted = "#f38ba8";
      };
    };
  };
}
