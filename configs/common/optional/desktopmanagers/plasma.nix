{
  lib,
  pkgs,
  config,
  username,
  inputs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  inherit (inputs) plasma-manager;

  cfg = config.nanoflake.desktop.plasma6;
in

{
  options.nanoflake.desktop.plasma6 = {
    enableWaylandDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Set Wayland as the default session";
    };

    withKdeConnect = mkEnableOption "KDE connect";
  };

  config = {
    services.desktopManager.plasma6.enable = true;
    programs.kdeconnect.enable = cfg.withKdeConnect;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      kate
      elisa
      kwrited
      okular
      print-manager
    ];

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = cfg.enableWaylandDefault;
      };

      autoLogin = {
        enable = true;
        user = username;
      };

      defaultSession = mkIf cfg.enableWaylandDefault "plasma";
    };

    xdg.portal = {
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = [ "kde" ];
    };

    home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

    hm = {
      xdg.portal = {
        extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
        config.common.default = [ "kde" ];
      };

      programs.plasma = {
        enable = true;

        shortcuts.kwin = {
          "Expose" = "Meta+Tab";
          "Maximize Window" = "Meta+Up";
          "Minimize Window" = "Meta+Down";
          "Maximise Window" = "Meta+Up";
          "Minimise Window" = "Meta+Down";
        };

        configFile =
          {
            "spectaclerc"."General"."autoSaveImage" = true;
            "spectaclerc"."General"."clipboardGroup" = "PostScreenshotCopyImage";
            "spectaclerc"."General"."launchAction" = "UseLastUsedCapturemode";
            "spectaclerc"."GuiConfig"."captureMode" = 0;

            "kscreenlockerrc"."Daemon"."LockGrace" = 30;
            "kscreenlockerrc"."Daemon"."Timeout" = 10;

            "kdeglobals"."KDE"."AnimationDurationFactor" = 0;
          }
          // lib.attrsets.optionalAttrs (config.i18n.inputMethod.type == "fcitx5") {
            "kwinrc"."Wayland"."InputMethod\[$e\]" =
              "/run/current-system/sw/share/applications/fcitx5-wayland-launcher.desktop";
          }
          // lib.attrsets.optionalAttrs config.hm.programs.alacritty.enable {
            "kdeglobals"."General"."TerminalApplication" = "alacritty";
          };
      };
    };

    environment.sessionVariables = mkIf cfg.enableWaylandDefault {
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland";
    };
  };
}
