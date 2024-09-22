{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.modules.plasma6;
in {
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
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
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
    ];

    programs.chromium.enablePlasmaBrowserIntegration = mkIf config.programs.chromium.enable true;

    programs.gamemode.settings.custom = mkIf config.programs.gamemode.enable {
      start = "qdbus org.kde.KWin /Compositor suspend";
      stop = "qdbus org.kde.KWin /Compositor resume";
    };
  };
}
