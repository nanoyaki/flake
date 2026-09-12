{ inputs, config, ... }:

{
  flake-file.inputs.niri.url = "github:nanoyaki/niri-flake/fix/infinite-recursion";

  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.niri ];
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.niri ];
  };

  modules.nixos.niri =
    { pkgs, ... }:

    {
      imports = [ inputs.niri.nixosModules.niri ];

      services.upower.enable = true;
      programs.niri.enable = true;

      # TODO: factor out into it's own module
      programs.xwayland.enable = true;
      environment.systemPackages = with pkgs; [
        xwayland-satellite
        brightnessctl
      ];
    };

  modules.home.niri =
    { lib, config, ... }:

    let
      inherit (config.lib.niri) actions;
    in

    {
      imports = [ inputs.niri.homeModules.niri ];

      programs.niri.settings = {
        workspaces = {
          browser = { };
          chat = { };
          term = { };
        };

        layer-rules = [
          {
            matches = [ { namespace = "^wallpaper$"; } ];
            place-within-backdrop = true;
          }
          {
            matches = [ { namespace = "^launcher$"; } ];
            opacity = 0.8;
            background-effect = {
              blur = true;
              xray = false;
            };
          }
        ];

        prefer-no-csd = true;
        window-rules = [
          {
            geometry-corner-radius = {
              bottom-left = 16.0;
              bottom-right = 16.0;
              top-left = 16.0;
              top-right = 16.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { app-id = "^signal$"; } ];
            open-on-workspace = "chat";
          }
          {
            matches = [ { app-id = "^Sable$"; } ];
            open-on-workspace = "chat";
          }
          {
            matches = [ { app-id = "^discord$"; } ];
            open-on-workspace = "chat";
          }
        ];

        layout = {
          focus-ring.enable = false;
          background-color = "transparent";

          border = {
            enable = true;
            width = 0;
            active.gradient = {
              angle = 0;
              from = "oklch(0.8025 0.1203 226.51)";
              to = "oklch(0.8118 0.0912 6.32)";
              in' = "oklch shorter hue";
            };
            inactive.gradient = {
              angle = 0;
              from = "oklch(0.8025 0.1203 226.51 / 20%)";
              to = "oklch(0.8118 0.0912 6.32 / 20%)";
              in' = "oklch shorter hue";
            };
          };

          preset-column-widths = [
            { proportion = 0.25; }
            { proportion = 0.5; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];

          preset-window-heights = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 1.0; }
          ];

          default-column-width.proportion = 0.5;

          gaps = 6;
          struts = {
            left = 0;
            right = 0;
            top = 0;
            bottom = 0;
          };

          tab-indicator = {
            hide-when-single-tab = true;
            place-within-column = true;
            position = "left";
            corner-radius = 20.0;
            gap = -12.0;
            gaps-between-tabs = 10.0;
            width = 4.0;
            length.total-proportion = 0.1;
          };
        };
        overview.zoom = 0.3;
        binds =
          {
            "Super+Shift+X".action.quit.skip-confirmation = false;
            "Super+Backspace".action = actions.spawn "fuzzel";
            "Super+Shift+Q".action = actions.close-window;
            "Shift+F11".action = actions.maximize-column;
            "Super+Shift+F11".action = actions.fullscreen-window;
            "Super+W".action = actions.switch-preset-column-width;
            "Super+Shift+W".action = actions.switch-preset-window-height;
            "Super+Shift+Space".action = actions.toggle-window-floating;
            "Super+F".action = actions.toggle-overview;
            "Super+F11".action = actions.show-hotkey-overlay;

            "Super+1".action = actions.focus-workspace "browser";
            "Super+2".action = actions.focus-workspace "chat";
            "Super+3".action = actions.focus-workspace "term";

            "Super+H".action = actions.focus-column-left;
            "Super+J".action = actions.focus-column-right;
            "Super+K".action = actions.focus-window-or-workspace-up;
            "Super+L".action = actions.focus-window-or-workspace-down;
            "Super+Left".action = actions.focus-column-left;
            "Super+Up".action = actions.focus-column-right;
            "Super+Down".action = actions.focus-window-or-workspace-up;
            "Super+Right".action = actions.focus-window-or-workspace-down;

            "Super+Shift+H".action = actions.move-column-left;
            "Super+Shift+J".action = actions.move-column-right;
            "Super+Shift+K".action = actions.move-column-to-workspace-up;
            "Super+Shift+L".action = actions.move-column-to-workspace-down;
            "Super+Shift+Left".action = actions.move-column-left;
            "Super+Shift+Up".action = actions.move-column-right;
            "Super+Shift+Down".action = actions.move-column-to-workspace-up;
            "Super+Shift+Right".action = actions.move-column-to-workspace-down;

            "Super+Control+H".action = actions.swap-window-left;
            "Super+Control+J".action = actions.swap-window-right;
            "Super+Control+K".action = actions.move-window-up-or-to-workspace-up;
            "Super+Control+L".action = actions.move-window-down-or-to-workspace-down;
            "Super+Control+Left".action = actions.swap-window-left;
            "Super+Control+Up".action = actions.swap-window-right;
            "Super+Control+Down".action = actions.move-window-up-or-to-workspace-up;
            "Super+Control+Right".action = actions.move-window-down-or-to-workspace-down;

            "Super+Comma".action = actions.consume-or-expel-window-left;
            "Super+Period".action = actions.consume-or-expel-window-right;

            Print.action.screenshot-screen = [ ];
            "Super+Shift+S".action.screenshot = [ ];

            XF86AudioRaiseVolume = {
              action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.1+"
              ];
              allow-when-locked = true;
            };
            XF86AudioLowerVolume = {
              action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "0.1-"
              ];
              allow-when-locked = true;
            };
            XF86AudioMute = {
              action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
              allow-when-locked = true;
            };
            XF86AudioMicMute = {
              action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
              allow-when-locked = true;
            };
            # Brightness
            XF86MonBrightnessUp = {
              action.spawn = [
                "brightnessctl"
                "s"
                "+5%"
              ];
              allow-when-locked = true;
            };
            XF86MonBrightnessDown = {
              action.spawn = [
                "brightnessctl"
                "s"
                "5%-"
              ];
              allow-when-locked = true;
            };
          };

        spawn-at-startup = [
          { command = [ "gnome-keyring-daemon" ]; }
          { command = [ "xwayland-satellite" ]; }
          { command = [ "firefox" ]; }
          { command = [ "signal-desktop" ]; }
          { command = [ "discord" ]; }
          { command = [ "sable-desktop" ]; }
        ];

        input.touchpad.natural-scroll = true;
        input.focus-follows-mouse.enable = true;

        environment = {
          CLUTTER_BACKEND = "wayland";
          GDK_BACKEND = "wayland";
          MOZ_ENABLE_WAYLAND = "1";
          NIXOS_OZONE_WL = "1";
          QT_QPA_PLATFORM = "wayland";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          SDL_VIDEODRIVER = "wayland";
        };
      };
    };

  modules.home.noctalia =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        programs.niri.settings = {
          binds."Super+Delete".action.spawn = [ "noctalia" "msg" "session" "lock" ];
          spawn-at-startup = [ { command = [ "noctalia" ]; } ];
          switch-events.lid-close.action.spawn = [
          "noctalia"
          "msg"
          "session"
          "lock"
        ];
        };
      };
    };

    modules.home.alacritty =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
      programs.niri.settings.binds."Super+T".action.spawn = "alacritty";
      programs.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^alacritty$"; } ];
          open-on-workspace = "term";
          background-effect = {
            blur = true;
            xray = false;
          };
        }
        {
          matches = [
            {
              app-id = "^alacritty$";
              is-focused = true;
            }
          ];
          opacity = 0.98;
        }
        {
          matches = [
            {
              app-id = "^alacritty$";
              is-focused = false;
            }
          ];
          opacity = 0.7;
        }
      ];
    };
    };

  modules.home.firefox =
  {lib, config, ...}:

  let
    inherit (lib) mkIf;
  in

  {
    config = mkIf config.programs.niri.enable {
      programs.niri.settings.window-rules = [
      {
        matches = [ { app-id = "^firefox$"; } ];
        open-on-workspace = "browser";
      }
      ];
    };
  };
}
