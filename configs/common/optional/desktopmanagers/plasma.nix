{
  lib,
  lib',
  pkgs,
  config,
  username,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    getExe
    getExe'
    ;
  inherit (lib') mkEnabledOption;

  inherit (inputs) plasma-manager;

  cfg = config.nanoflake.desktop.plasma6;
in

{
  options.nanoflake.desktop.plasma6 = {
    enableWaylandDefault = mkEnabledOption "Wayland as the default session";

    withKdeConnect = mkEnableOption "KDE connect";

    withOcrShortcut = mkEnabledOption "the ocr shortcut";
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
      xdg =
        {
          portal = {
            extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
            config.common.default = [ "kde" ];
          };
        }
        // lib.optionalAttrs cfg.withOcrShortcut {
          desktopEntries.ocr-ja = {
            name = "OCR image: jpn";
            exec = "${pkgs.writeShellScript "ocr" ''
              IMAGE_FILE="/tmp/ocr-$RANDOM-tmp.png"
              TEXT_FILE="/tmp/ocr-$RANDOM-tmp"

              ${getExe pkgs.kdePackages.spectacle} -r -e -S -n -b -o $IMAGE_FILE || exit 1
              ${getExe pkgs.tesseract} -l "jpn" $IMAGE_FILE $TEXT_FILE
              ${getExe pkgs.translate-shell} -b -s japanese -t english "$(cat "$TEXT_FILE.txt")" > "$TEXT_FILE.txt"
              ${getExe' pkgs.wl-clipboard "wl-copy"} < "$TEXT_FILE.txt"

              rm $IMAGE_FILE "$TEXT_FILE.txt"
            ''}";
          };
        };

      programs.plasma = {
        enable = true;

        shortcuts."ocr-ja.desktop"._launch = "Ctrl+Print";
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
