{
  lib,
  lib',
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (inputs) plasma-manager;
  inherit (lib'.options) mkFalseOption;
  inherit (lib) mkIf;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = [ "kde" ];
  };

  cfg = config.config'.plasmaOverCosmic;
in

{
  options.config'.plasmaOverCosmic = mkFalseOption;

  config = mkIf cfg {
    services.desktopManager.cosmic.enable = lib.mkForce false;
    services.displayManager.cosmic-greeter.enable = lib.mkForce false;

    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      kate
      elisa
      kwrited
      okular
      print-manager
      krdp
    ];

    services.displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;

      defaultSession = lib.mkForce "plasma";
    };

    inherit xdg;
    hms = [
      plasma-manager.homeModules.plasma-manager
      {
        inherit xdg;

        programs.plasma = {
          enable = true;

          shortcuts.kwin = {
            Expose = "Meta+Tab";
            "Maximize Window" = "Meta+Up";
            "Minimize Window" = "Meta+Down";
            "Maximise Window" = "Meta+Up";
            "Minimise Window" = "Meta+Down";
          };

          configFile = {
            spectaclerc.GuiConfig.captureMode = 0;
            spectaclerc.General = {
              autoSaveImage = true;
              clipboardGroup = "PostScreenshotCopyImage";
              launchAction = "UseLastUsedCapturemode";
            };

            kscreenlockerrc.Daemon = {
              LockGrace = 30;
              Timeout = 10;
            };

            kdeglobals.KDE.AnimationDurationFactor = 0;
            kdeglobals.General.TerminalApplication = "alacritty";
          };
        };
      }
    ];
  };
}
