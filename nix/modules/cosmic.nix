{ withSystem, inputs, ... }:

{
  perSystem =
    { inputs', pkgs, ... }:

    {
      packages.gradia-cosmic = pkgs.writeShellApplication {
        name = "gradia-cosmic";
        runtimeInputs = with pkgs; [
          gradia
          wl-clipboard
        ];
        text = ''
          set -e

          GRADIA_CACHE="$HOME/.var/app/be.alexandervanhee.gradia/cache/gradia/stdin"
          [[ -d "$GRADIA_CACHE" ]] && rm -rf "''${GRADIA_CACHE:?}/"*

          cosmic-screenshot --interactive &&
          while ! wl-paste --list-types 2> /dev/null | grep -q image/png; do
            sleep 0.05
          done

          wl-paste --type image/png | gradia
        '';
      };

      packages.cosmic-ext-applet-privacy-indicator =
        inputs'.nanopkgs.packages.cosmic-ext-applet-privacy-indicator.overrideAttrs
          (
            finalAttrs: _: {
              src = pkgs.applyPatches {
                name = "${finalAttrs.pname}-${finalAttrs.version}";
                src = pkgs.fetchFromGitHub {
                  owner = "D-Brox";
                  repo = "cosmic-ext-applet-privacy-indicator";
                  rev = "e69833cf8b31813d5468da7eeea6311f1621d702";
                  hash = "sha256-LivssKbrzAO4kuoNcE6evs4etaiFgH0UWeOSzHtgd1A=";
                };
                patches = [ ./no-blink.patch ];
              };

              cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
                inherit (finalAttrs) src;
                hash = "sha256-8Q4Cphr3jNcHpfeFchvLcGIM6pecJ5xzXCSUU2/YrFs=";
              };
            }
          );
    };

  flake.overlays.cosmic =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) gradia-cosmic cosmic-ext-applet-privacy-indicator;
      }
    );

  flake.nixosModules.cosmic =
    { pkgs, ... }:

    {
      services.desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };

      environment.cosmic.excludePackages = with pkgs; [
        cosmic-term
        cosmic-edit
        cosmic-store
        cosmic-player
      ];

      environment.systemPackages = with pkgs; [
        cosmic-ext-applet-privacy-indicator
        cosmic-ext-connected
        # leads to crashes on paste
        # clipboard-manager
        wkeys
        gradia
        loupe
      ];

      # KDEConnect
      networking.firewall = rec {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };

      environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
      xdg.mime.defaultApplications."image/*" = "org.gnome.Loupe.desktop";

      services.displayManager.cosmic-greeter.enable = true;
      services.displayManager.defaultSession = "cosmic";
    };

  flake.homeModules.cosmic =
    {
      lib,
      config,
      pkgs,
      ...
    }:

    let
      inherit (config.lib.cosmic) mkRON;

      Tuple = mkRON "tuple";
      # NamedStruct = mkRON "namedStruct";
      Map = mkRON "map";
      Enum = mkRON "enum";
      EnumVariant =
        variant: value:
        mkRON "enum" {
          value = if builtins.isList value then value else [ value ];
          inherit variant;
        };
      # Char = mkRON "char";
      # Raw = mkRON "raw";
      Some = mkRON "optional";
      None = mkRON "optional" null;

      mins = ms: 1000 * 60 * ms;
    in

    {
      imports = [
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
      ];

      home.packages = with pkgs; [
        gradia-cosmic
        kooha
      ];

      xdg.mimeApps.defaultApplications."image/*" = "org.gnome.Loupe.desktop";

      services.kdeconnect.enable = true;

      programs.cosmic-files = {
        enable = true;
        package = null;
        settings = {
          app_theme = Enum "System";

          desktop = {
            show_content = false;
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
                # leads to crashes on paste
                # "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager"
                "io.github.nwxnw.cosmic-ext-connected"
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
            source = EnumVariant "Path" pkgs.default-wallpaper.outPath;
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

            header_size = Enum "Standard";
            interface_density = Enum "Standard";

            show_maximize = true;
            show_minimize = true;
          };

          theme.mode = "dark";
        };

        applets.app-list.settings = {
          favorites = [
            "com.system76.CosmicFiles"
            "thunderbird"
            "librewolf"
            "alacritty"
            "vesktop"
            "codium"
            "steam"
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
            layout = "de";
            variant = "";
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
          {
            action = EnumVariant "Spawn" "gradia-cosmic";
            key = "Super+Shift+S";
          }
          {
            action = EnumVariant "Spawn" "kooha";
            key = "Super+Shift+V";
          }
        ];

        stateFile."com.system76.CosmicSettingsDaemon" = {
          version = 1;
          entries.default_sink_name = "\"@DEFAULT_SINK@\"";
        };
      };
    };
}
