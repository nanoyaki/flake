{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.plasma6;
in
{
  options.modules.plasma6 = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom plasma 6 options.";
    };

    isWaylandDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Set Wayland as the default session.";
    };
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      catppuccin = {
        enable = true;
        assertQt6Sddm = true;
        flavor = "macchiato";
        background = /home/hana/Pictures/Wallpaper/Wallpaper.png;
        loginBackground = true;
      };
    };
    services.displayManager.defaultSession = mkIf cfg.isWaylandDefault "plasma";

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      kate
      elisa
      kwrited
      ark
      okular
      print-manager
    ];
    programs.kdeconnect.enable = false;

    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qttools
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

    programs.chromium.enablePlasmaBrowserIntegration = config.programs.chromium.enable;

    # programs.gamemode.settings.custom = mkIf config.programs.gamemode.enable {
    #   start = "qdbus org.kde.KWin /Compositor suspend";
    #   stop = "qdbus org.kde.KWin /Compositor resume";
    # };
  };
}
