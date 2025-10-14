{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

let
  inherit (config.hm.lib.cosmic) mkRON;

  Tuple = mkRON "tuple";
  NamedStruct = mkRON "namedStruct";
  Map = mkRON "map";
  Enum = mkRON "enum";
  EnumVariant =
    variant: value:
    mkRON "enum" {
      value = [ value ];
      inherit variant;
    };
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
    ];

    environment.systemPackages = with pkgs; [
      cosmic-ext-applet-privacy-indicator
      clipboard-manager
      wkeys
    ];

    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

    hm = {
      programs.cosmic-files = {
        inherit (config.services.desktopManager.cosmic) enable;
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

      home.activation = lib.mkIf (with config.hm.wayland.desktopManager.cosmic; resetFiles && enable) {
        killCosmicPanel = config.hm.lib.dag.entryAfter [ "configureCosmic" ] ''
          exec ${lib.getExe' pkgs.procps "pkill"} cosmic-panel
        '';
      };

      xdg.configFile."wkeys/style.css".text = ''
        :root {
          color: rgb(205, 214, 244);
          font-size: 12px;
        }

        window {
          background-color: rgba(0, 0, 0, 0);
        }

        button {
          background-color: rgb(30, 30, 46);
          border-radius: 0.5rem;
          margin: 1px;
          padding: 0.5rem;
        }

        button:hover {
          background-color: rgb(108, 112, 134);
        }

        button:active {
          background-color: rgb(245, 194, 231);
        }

        button:checked {
          background-color: rgb(245, 194, 231);
        }
      '';

      programs.cosmic-manager = {
        inherit (config.services.desktopManager.cosmic) enable;
      };

      wayland.desktopManager.cosmic = {
        inherit (config.services.desktopManager.cosmic) enable;

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
            name = "Dock";

            # Behaviour
            anchor = Enum "Bottom";
            layer = Enum "Top";
            anchor_gap = false;
            expand_to_edges = true;
            exclusive_zone = true;
            autohide = None;
            autohover_delay_ms = None;
            size = null;
            size_wings = Some (Tuple [
              (Some (Enum "XS"))
              (Some (Enum "XS"))
            ]);
            size_center = Some (Enum "S");
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
                "com.system76.CosmicAppletPower"
                "dev.DBrox.CosmicPrivacyIndicator"
              ]
              [
                "com.system76.CosmicAppletStatusArea"
                "com.system76.CosmicAppletInputSources"
                "net.pithos.applet.wkeys"
                "com.system76.CosmicAppletTiling"
                "com.system76.CosmicAppletNotifications"
                "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager"
                "com.system76.CosmicAppletBluetooth"
                "com.system76.CosmicAppletNetwork"
                "com.system76.CosmicAppletAudio"
                "com.system76.CosmicAppletBattery"
                "com.system76.CosmicAppletTime"
              ]
            ]);
            plugins_center = Some [
              "com.system76.CosmicAppList"
            ];
          }
        ];

        wallpapers = [
          {
            output = "all";
            source = EnumVariant "Path" ./wallpaper.png;
            filter_by_theme = true;
            rotation_frequency = 300;
            filter_method = Enum "Lanczos";
            scaling_mode = Enum "Zoom";
            sampling_method = Enum "Alphanumeric";
          }
        ];

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
            "codium"
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
            action = EnumVariant "System" (Enum "AppLibrary");
            key = "Super";
          }
        ];

        stateFile."com.system76.CosmicSettingsDaemon" = {
          version = 1;
          entries.default_sink_name = "\"@DEFAULT_SINK@\"";
        };
      };
    };
  };
}
