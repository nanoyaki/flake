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

  inherit catppuccin;

  environment.systemPackages = [
    pkgs.catppuccin-cursors.mochaPink

    (pkgs.catppuccin-papirus-folders.override {
      flavor = catppuccin.flavor;
      accent = catppuccin.accent;
    })

    (pkgs.catppuccin.override {
      accent = catppuccin.accent;
      variant = catppuccin.flavor;
    })

    (lib.mkIf config.services.desktopManager.plasma6.enable (
      pkgs.catppuccin-kde.override {
        flavour = [ catppuccin.flavor ];
        accents = [ catppuccin.accent ];
      }
    ))
  ];

  services.displayManager.sddm.catppuccin = lib.mkIf config.services.displayManager.sddm.enable {
    enable = true;
    assertQt6Sddm = true;
    flavor = "mocha";
    background = "/home/hana/Pictures/Wallpaper/Wallpaper.png";
    loginBackground = true;
  };

  hm.catppuccin = {
    inherit (catppuccin) enable flavor accent;
    pointerCursor = {
      inherit (catppuccin) enable flavor accent;
    };
  };
}
