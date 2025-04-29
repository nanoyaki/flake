{
  lib,
  pkgs,
  config,
  username,
  ...
}:

{
  options.nanoflake.desktop.sway = true;

  config = {
    users.users.${username}.extraGroups = [ "video" ];

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      extraPackages = with pkgs; [
        pulseaudio
        swayidle
        swaylock
        wmenu

        wl-clipboard
        kdePackages.dolphin
        rofi-wayland
        greetd.qtgreet
      ];

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export QT_WAYLAND_FORCE_DPI=physical
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export ECORE_EVAS_ENGINE=wayland_egl
        export ELM_ENGINE=wayland_egl
      '';
    };

    systemd.user.services.kanshi = {
      description = "kanshi daemon";

      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DISPLAY = ":0";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = ''${lib.getExe pkgs.kanshi} -c ${pkgs.writeText "kanshi_config" ''
          profile default {
            output DP-2 disable
            output "AOC 2470W F03F9BA002111" mode 1920x1080@60.000Hz position 0,0
            output "AOC 24G2W1G4 0x000010D8" mode 1920x1080@144.001Hz position 1921,0
          }
        ''}'';
      };

      wantedBy = [ "sway-session.target" ];
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "sway --config ${pkgs.greetd.qtgreet}/etc/qtgreet/sway.cfg";
          user = config.users.users.greeter.name;
        };
      };
    };

    xdg.portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.Inhibit" = "none";
      };
    };

    programs.waybar.enable = true;

    security.polkit.enable = lib.mkDefault true;

    environment.sessionVariables.XDG_CURRENT_DESKTOP = "sway";

    hm = {
      home.sessionVariables.XDG_CURRENT_DESKTOP = "sway";

      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
        config.common = config.xdg.portal.config.sway;
      };

      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        location = "center";
        terminal = lib.getExe pkgs.alacritty;
      };

      wayland.windowManager.sway = {
        inherit (config.programs.sway) enable wrapperFeatures;

        config = rec {
          modifier = "Mod4";
          terminal = lib.getExe pkgs.alacritty;
          menu = "${lib.getExe config.hm.programs.rofi.finalPackage} -show drun";

          colors = rec {
            background = "$base";

            focused = {
              inherit background;
              border = "$lavender";
              childBorder = "$lavender";
              indicator = "$rosewater";
              text = "$text";
            };

            focusedInactive = {
              inherit background;
              border = "$overlay0";
              childBorder = "$overlay0";
              indicator = "$rosewater";
              text = "$text";
            };

            unfocused = focusedInactive;

            urgent = {
              inherit background;
              border = "$peach";
              childBorder = "$peach";
              indicator = "$overlay0";
              text = "$peach";
            };

            placeholder = {
              inherit background;
              border = "$overlay0";
              childBorder = "$overlay0";
              indicator = "$overlay0";
              text = "$text";
            };
          };

          keybindings = lib.mkOptionDefault {
            "${modifier}+Return" = "exec ${lib.getExe pkgs.alacritty}";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+d" = "exec ${lib.getExe config.hm.programs.rofi.finalPackage} -show drun";
            "${modifier}+f" = "exec $EDITOR $FLAKE_DIR";
          };

          input."*".xkb_layout = config.services.xserver.xkb.layout;

          fonts = {
            names = [
              "Noto Sans"
              "Cascadia Mono"
              "Twitter Color Emoji"
            ];
            style = "Regular";
            size = 10.0;
          };

          window.titlebar = false;
          floating.titlebar = false;

          gaps = {
            horizontal = 6;
            vertical = 6;
            smartGaps = true;
          };

          bars = [ ];
        };

        systemd.xdgAutostart = true;
        systemd.variables = [ "--all" ];
      };

      services.swaync.enable = true;

      programs.waybar.enable = true;

      home.packages = [ pkgs.rofi-power-menu ];
    };
  };
}
