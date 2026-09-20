{
  inputs,
  lib,
  config,
  ...
}:

let
  inherit (lib) optionals optionalAttrs;

  mkWindowRules =
    {
      app-id,
      open-on-workspace,
      blur ? false,
    }:
    [
      (
        {
          matches = [ { inherit app-id; } ];
          inherit open-on-workspace;
        }
        // optionalAttrs blur {
          background-effect = {
            blur = true;
            xray = false;
          };
        }
      )
    ]
    ++ optionals blur [
      {
        matches = [
          {
            inherit app-id;
            is-focused = true;
          }
        ];
        opacity = 0.97;
      }
      {
        matches = [
          {
            inherit app-id;
            is-focused = false;
          }
        ];
        opacity = 0.7;
      }
    ];
in

{
  flake-file.inputs.niri.url = "github:nanoyaki/niri-flake/fix/infinite-recursion";

  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.niri ];
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.niri ];
  };

  modules.nixos.niri =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkOption types;
    in

    {
      imports = [ inputs.niri.nixosModules.niri ];

      options.programs.niri.requiredPackages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          xwayland-satellite
          brightnessctl
          wireplumber
          nautilus
        ];
        defaultText = "with pkgs; [ xwayland-satellite brightnessctl ]";
      };

      config = {
        services.upower.enable = true;
        programs.niri.enable = true;

        programs.nautilus-open-any-terminal.enable = true;
        programs.nautilus-open-any-terminal.terminal = "alacritty";

        # TODO: factor out into it's own module
        programs.xwayland.enable = true;
        environment.systemPackages = config.programs.niri.requiredPackages;
      };
    };

  modules.home.niri =
    { lib, config, ... }:

    let
      inherit (lib) optional;
      inherit (config.lib.niri) actions;
    in

    {
      imports = [ inputs.niri.homeModules.niri ];

      programs.niri.enable = true;
      programs.niri.settings = {
        workspaces = {
          "01-browser".name = "browser";
          "02-term".name = "term";
          "03-chat".name = "chat";
        };

        blur = {
          passes = 2;
          offset = 3.0;
          noise = 0.03;
          saturation = 1.0;
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
            matches = [ { app-id = "^Sable$"; } ];
            open-on-workspace = "chat";
          }
        ]
        ++ optional (!config.programs.noctalia.enable) {
          geometry-corner-radius = {
            bottom-left = 16.0;
            bottom-right = 16.0;
            top-left = 16.0;
            top-right = 16.0;
          };
          clip-to-geometry = true;
        };

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
        binds = {
          "Mod+Shift+X".action.quit.skip-confirmation = false;
          "Mod+Shift+Q".action = actions.close-window;
          F11.action = actions.show-hotkey-overlay;
          "Mod+F11".action = actions.maximize-column;
          "Mod+Shift+F11".action = actions.fullscreen-window;
          "Mod+W".action = actions.switch-preset-column-width;
          "Mod+Shift+W".action = actions.switch-preset-window-height;
          "Mod+Shift+Space".action = actions.toggle-window-floating;
          "Mod+Tab".action = actions.toggle-overview;

          "Mod+1".action = actions.focus-workspace "browser";
          "Mod+2".action = actions.focus-workspace "chat";
          "Mod+3".action = actions.focus-workspace "term";

          "Mod+Left".action = actions.focus-column-left;
          "Mod+Right".action = actions.focus-column-right;
          "Mod+Up".action = actions.focus-window-or-workspace-up;
          "Mod+Down".action = actions.focus-window-or-workspace-down;

          "Mod+Shift+Left".action = actions.move-column-left;
          "Mod+Shift+Right".action = actions.move-column-right;
          "Mod+Shift+Up".action = actions.move-column-to-workspace-up;
          "Mod+Shift+Down".action = actions.move-column-to-workspace-down;

          "Mod+Control+Left".action = actions.swap-window-left;
          "Mod+Control+Right".action = actions.swap-window-right;
          "Mod+Control+Up".action = actions.move-window-up-or-to-workspace-up;
          "Mod+Control+Down".action = actions.move-window-down-or-to-workspace-down;

          "Mod+Comma".action = actions.consume-or-expel-window-left;
          "Mod+Period".action = actions.consume-or-expel-window-right;

          Print.action.screenshot-screen = [ ];
          "Mod+Shift+S".action.screenshot = [ ];
        }
        // (lib.optionalAttrs (!config.programs.noctalia.enable) {
          XF86AudioRaiseVolume.allow-when-locked = true;
          XF86AudioRaiseVolume.action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.05+"
          ];

          XF86AudioLowerVolume.allow-when-locked = true;
          XF86AudioLowerVolume.action.spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.05-"
          ];

          XF86AudioMute.allow-when-locked = true;
          XF86AudioMute.action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];

          XF86AudioMicMute.allow-when-locked = true;
          XF86AudioMicMute.action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];

          # Brightness
          XF86MonBrightnessUp.allow-when-locked = true;
          XF86MonBrightnessUp.action.spawn = [
            "brightnessctl"
            "s"
            "+5%"
          ];

          XF86MonBrightnessDown.allow-when-locked = true;
          XF86MonBrightnessDown.action.spawn = [
            "brightnessctl"
            "s"
            "5%-"
          ];
        });

        spawn-at-startup = [ { command = [ "xwayland-satellite" ]; } ];

        input = {
          touchpad.natural-scroll = true;
          focus-follows-mouse.enable = true;
          keyboard.xkb.layout = "de";
        };

        cursor.theme = "Wii-Pointer-P1";
        cursor.size = 36;

        environment = {
          CLUTTER_BACKEND = "wayland";
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
      inherit (lib) mkIf mapAttrs;
    in

    {
      config = mkIf config.programs.niri.enable {
        programs.niri.settings = {
          spawn-at-startup = [ { command = [ "noctalia" ]; } ];

          layer-rules = [
            # Blurry copy of the wallpaper in the overview
            {
              matches = [ { namespace = "^noctalia-backdrop"; } ];
              place-within-backdrop = true;
            }
            # More blur
            {
              matches = [
                { namespace = ''^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$''; }
              ];
              background-effect.xray = false;
            }
            {
              matches = [ { namespace = "noctalia-window-switcher"; } ];
              background-effect.blur = true;
              background-effect.xray = false;
            }
          ];

          window-rules = [
            {
              geometry-corner-radius = {
                bottom-left = 20.0;
                bottom-right = 20.0;
                top-left = 20.0;
                top-right = 20.0;
              };
              clip-to-geometry = true;
            }
            {
              matches = [ { app-id = "dev.noctalia.Noctalia"; } ];
              open-floating = true;
              default-column-width.fixed = 1080;
              default-window-height.fixed = 920;
            }
          ];

          debug.honor-xdg-activation-with-invalid-serial = { };

          binds =
            mapAttrs
              (
                key: cfg:
                if cfg ? action.spawn then
                  cfg
                  // {
                    action.spawn = [
                      "noctalia"
                      "msg"
                    ]
                    ++ cfg.action.spawn;
                  }
                else
                  cfg
              )
              {
                "Mod+Space".action.spawn = [
                  "panel-toggle"
                  "launcher"
                ];
                "Mod+S".action.spawn = [
                  "panel-toggle"
                  "control-center"
                ];
                "Mod+L".action.spawn = [
                  "session"
                  "lock"
                ];
                "Mod+V".action.spawn = [
                  "panel-toggle"
                  "clipboard"
                ];
                "Mod+Minus".action.spawn = [ "settings-toggle" ];
                "Alt+Tab".action.spawn = [
                  "window-switcher"
                ];

                XF86AudioMicMute.action.spawn = [ "mic-mute" ];
                XF86AudioMute.action.spawn = [ "volume-mute" ];
                XF86AudioRaiseVolume.action.spawn = [
                  "volume-up"
                  "5"
                ];
                XF86AudioLowerVolume.action.spawn = [
                  "volume-down"
                  "5"
                ];

                # Brightness
                XF86MonBrightnessUp.action.spawn = [
                  "brightness-up"
                  "5"
                ];
                XF86MonBrightnessDown.action.spawn = [
                  "brightness-down"
                  "5"
                ];
              };

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
        programs.niri.settings.spawn-at-startup = [ { command = [ "alacritty" ]; } ];
        programs.niri.settings.binds."Mod+T".action.spawn = "alacritty";
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "^Alacritty$";
          open-on-workspace = "term";
          blur = true;
        };
      };
    };

  modules.home.firefox =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        programs.niri.settings.spawn-at-startup = [ { command = [ "firefox" ]; } ];
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "^firefox$";
          open-on-workspace = "browser";
        };
      };
    };

  modules.home.thunderbird =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        programs.niri.settings.spawn-at-startup = [ { command = [ "thunderbird" ]; } ];
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "^thunderbird$";
          open-on-workspace = "chat";
        };
      };
    };

  modules.home.zed =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "dev.zed.Zed";
          open-on-workspace = "term";
          blur = true;
        };
      };
    };

  modules.home.discord =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        # programs.niri.settings.spawn-at-startup = [ { command = [ "equibop" ]; } ];
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "^equibop$";
          open-on-workspace = "chat";
          blur = true;
        };
      };
    };

  modules.home.signal =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        # programs.niri.settings.spawn-at-startup = [ { command = [ "signal-desktop" ]; } ];
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "^signal$";
          open-on-workspace = "chat";
          blur = true;
        };
      };
    };

  modules.home.matrix-client =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        # programs.niri.settings.spawn-at-startup = [ { command = [ "fluffychat" ]; } ];
        programs.niri.settings.window-rules = mkWindowRules {
          app-id = "^fluffychat$";
          open-on-workspace = "chat";
          blur = true;
        };
      };
    };

  modules.home.oo7 =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.niri.enable {
        programs.niri.settings.spawn-at-startup = [ { command = [ "oo7-daemon" ]; } ];
      };
    };
}
