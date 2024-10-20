{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.modules.plasma6;
in

{
  options.modules.plasma6.isWaylandDefault = mkOption {
    type = types.bool;
    default = true;
    description = "Set Wayland as the default session.";
  };

  config = {
    services.desktopManager.plasma6.enable = true;
    programs.kdeconnect.enable = false;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      kate
      elisa
      kwrited
      ark
      okular
      print-manager
    ];

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = cfg.isWaylandDefault;
        catppuccin = {
          enable = true;
          assertQt6Sddm = true;
          flavor = "macchiato";
          background = "/home/hana/Pictures/Wallpaper/Wallpaper.png";
          loginBackground = true;
        };
      };

      autoLogin = {
        enable = true;
        user = username;
      };

      defaultSession = mkIf cfg.isWaylandDefault "plasma";
    };

    environment.systemPackages = with pkgs; [
      catppuccin-cursors.macchiatoPink
      (catppuccin.override {
        accent = "pink";
        variant = "macchiato";
      })
      (catppuccin-kde.override {
        flavour = [ "macchiato" ];
        accents = [ "pink" ];
      })
      (catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "pink";
      })
    ];

    programs.kde-pim.merkuro = true;
  };
}
