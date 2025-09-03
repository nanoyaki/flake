{
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (inputs) plasma-manager;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = [ "kde" ];
  };
in

{
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

    autoLogin.enable = true;
    autoLogin.user = config.config'.mainUserName;

    defaultSession = "plasma";
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

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GDK_BACKEND = "wayland";
  };
}
