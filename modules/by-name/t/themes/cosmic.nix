{
  lib,
  inputs,
  config,
  ...
}:

let
  inherit (config.hm.lib.cosmic) mkRON;

  Tuple = mkRON "tuple";
  NamedStruct = mkRON "namedStruct";
  Map = mkRON "map";
  Enum = mkRON "enum";
  Char = mkRON "char";
  Raw = mkRON "raw";
  Some = mkRON "optional";
  None = mkRON "optional" null;

  mins = ms: 1000 * 60 * ms;
in
{
  options = { };

  config = lib.mkIf config.config'.theming.enable {
    hms = [
      inputs.cosmic-manager.homeManagerModules.cosmic-manager
      {
        programs.cosmic-files = {
          enable = true;
          settings = {
            app_theme = Enum "System";

            desktop = {
              show_content = true;
              show_mounted_drives = false;
              show_trash = false;
            };

            favorites = [
              (Enum "Home")
              (Enum "Documents")
              (Enum "Downloads")
              (Enum "Music")
              (Enum "Pictures")
              (Enum "Videos")
            ];

            show_details = true;

            tab = {
              icon_sizes.grid = 100;
              icon_sizes.list = 100;

              folders_first = true;
              show_hidden = false;
              view = Enum "Grid";
            };
          };
        };

        programs.cosmic-manager.enable = true;

        wayland.desktopManager.cosmic = {
          enable = true;

          idle = {
            screen_off_time = Some (mins 15);
            suspend_on_ac_time = Some (mins 30);
          };

          systemActions = Map [
            {
              key = Enum "Terminal";
              value = "alacritty";
            }
          ];

          panels = [
            {
              name = "Panel";

              anchor = Enum "Top";
              layer = Enum "Top";
              anchor_gap = false;
              expand_to_edges = true;
              exclusive_zone = false;
              autohide = Some {
                handle_size = 2;
                transition_time = 100;
                wait_time = 250;
              };
              autohover_delay_ms = Some 250;
              size = Enum "XS";
              size_wings = Some (Tuple [
                None
                (Some (Enum "XS"))
              ]);
              size_center = None;
              background = Enum "ThemeDefault";
              output = Enum {
                value = [
                  "DP-1"
                ];
                variant = "Name";
              };
              keyboard_interactivity = Enum "OnDemand";

              padding = 0;
              border_radius = 160;
              opacity = 1.0;
              margin = 0;
              spacing = 4;

              plugins_wings = Some (Tuple [
                [ ]
                [
                  "com.system76.CosmicAppletNotifications"
                  "com.system76.CosmicAppletTiling"
                  "com.system76.CosmicAppletAudio"
                  "com.system76.CosmicAppletBluetooth"
                  "com.system76.CosmicAppletNetwork"
                  "com.system76.CosmicAppletBattery"
                  "com.system76.CosmicAppletPower"
                ]
              ]);
              plugins_center = Some [ ];
            }
            {
              name = "Dock";

              # Behaviour
              anchor = Enum "Bottom";
              layer = Enum "Top";
              anchor_gap = false;
              expand_to_edges = true;
              exclusive_zone = true;
              autohide = None;
              autohover_delay_ms = None;
              size = Enum "M";
              size_wings = Some (Tuple [
                (Some (Enum "M"))
                (Some (Enum "XS"))
              ]);
              size_center = None;
              background = Enum "ThemeDefault";
              output = Enum "All";
              keyboard_interactivity = Enum "OnDemand";

              # CSS like styling
              padding = 0;
              border_radius = 0;
              opacity = 1.0;
              margin = 0;
              spacing = 4;

              # Content
              plugins_wings = Some (Tuple [
                [
                  "com.system76.CosmicPanelAppButton"
                  "com.system76.CosmicAppList"
                ]
                [
                  "com.system76.CosmicAppletStatusArea"
                  "com.system76.CosmicAppletInputSources"
                  "com.system76.CosmicAppletTime"
                ]
              ]);
              plugins_center = None;
            }
          ];

          wallpapers = [ ];

          appearance = {
            toolkit = {
              apply_theme_global = true;
              icon_theme = "Papirus-Dark";

              header_size = Enum "Standard";
              interface_density = Enum "Standard";

              interface_font = {
                family = "Open Sans";
                stretch = Enum "Normal";
                style = Enum "Normal";
                weight = Enum "Normal";
              };

              monospace_font = {
                family = "Noto Sans Mono";
                stretch = Enum "Normal";
                style = Enum "Normal";
                weight = Enum "Normal";
              };

              show_maximize = true;
              show_minimize = true;
            };

            theme.mode = "dark";
            theme.dark = import ./catppuccin-mocha-pink.nix {
              inherit
                Tuple
                NamedStruct
                Map
                Enum
                Char
                Raw
                Some
                None
                ;
            };
          };

          applets.app-list.settings = {
            favorites = [
              "com.system76.CosmicFiles"
              "librewolf"
              "alacritty"
              "vesktop"
            ];
            enable_drag_source = true;
            filter_top_levels = None;
          };

          applets.time.settings = {
            first_day_of_week = 0;
            military_time = true;
            show_date_in_top_panel = true;
            show_seconds = false;
            show_weekday = false;
          };

          compositor = {
            active_hint = true;
            descale_xwayland = false;
            edge_snap_threshold = 10;

            cursor_follows_focus = true;
            focus_follows_cursor = false;
            focus_follows_cursor_delay = 250;

            autotile = true;
            autotile_behavior = Enum "PerWorkspace";

            workspaces.workspace_layout = Enum "Vertical";
            workspaces.workspace_mode = Enum "OutputBound";

            input_default = {
              acceleration = Some {
                profile = Some (Enum "Flat");
                speed = 0.0;
              };
              state = Enum "Enabled";
            };

            keyboard_config.numlock_state = Enum "BootOff";

            xkb_config = {
              inherit (config.nanoSystem.keyboard) layout variant;
              model = lib.mkDefault "";
              rules = lib.mkDefault "";

              options = Some "terminate:ctrl_alt_bksp";
              repeat_delay = 600;
              repeat_rate = 25;
            };
          };

          shortcuts = [
            {
              action = Enum {
                value = [
                  (Enum "AppLibrary")
                ];
                variant = "System";
              };
              key = "Super";
            }
          ];

          resetFiles = true;

          stateFile."com.system76.CosmicSettingsDaemon" = {
            version = 1;
            entries.default_sink_name = "\"@DEFAULT_SINK@\"";
          };
        };
      }
    ];
  };
}
