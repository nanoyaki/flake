{ withSystem, config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.noctalia ];
  };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.noctalia ];
  };

  modules.nixos.noctalia =
    { config, ... }:

    {
      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
        systemd.enable = true;
      };

      services.displayManager.noctalia-greeter = {
        enable = true;

        settings.cursor.size = 32;
        settings.keyboard.layout = "de";

        cursorTheme = {
          package = withSystem config.nixpkgs.hostPlatform.system ({ config, ... }: config.packages.cursor);
          name = "Wii-Pointer-P1";
        };
      };
    };

  modules.home.noctalia = { pkgs, config, ... }: {
    home.file."${config.xdg.userDirs.pictures}/Wallpapers/01.png".source =
      withSystem pkgs.stdenv.hostPlatform.system
        ({ config, ... }: config.packages.wallpaper);

    programs.noctalia.enable = true;
    programs.noctalia.settings = {
      bar.default = {
        start = [
          "launcher"
          "Spacer"
          "workspaces"
        ];
        center = [ "group:center-group" ];
        end = [
          "media"
          "tray"
          "clipboard"
          "notifications"
          "volume"
          "group:network-group"
          "group:power-group"
          "session"
        ];

        background_opacity = 0.97;
        margin_ends = 0;
        position = "bottom";
        radius = 0;
        radius_top_left = 12;
        radius_top_right = 12;
        shadow = false;
        thickness = 48;
        widget_spacing = 8;
        capsule_group = [
          {
            accordion = true;
            accordion_direction = "start";
            enabled = true;
            fill = "surface_variant";
            id = "network-group";
            members = [
              "network"
              "bluetooth"
            ];
            opacity = 0.0;
            padding = 0.0;
          }
          {
            accordion = true;
            accordion_direction = "start";
            enabled = true;
            fill = "surface_variant";
            id = "power-group";
            members = [
              "battery"
              "brightness"
            ];
            opacity = 0.0;
            padding = 0.0;
          }
          {
            accordion = true;
            accordion_direction = "end";
            enabled = true;
            fill = "surface_variant";
            id = "center-group";
            members = [
              "clock"
              "wallpaper"
            ];
            opacity = 0.0;
            padding = 8.0;
          }
        ];
      };

      battery.warning_threshold = 15;
      calendar.enabled = true;

      control_center = {
        show_shortcut_labels = false;
        calendar.show_events_card = true;
      };

      idle.behavior = {
        lock = {
          action = "lock";
          enabled = true;
          timeout = 600.0;
        };

        screen-off = {
          action = "screen_off";
          enabled = true;
          timeout = 660.0;
        };

        lock-and-suspend = {
          action = "lock_and_suspend";
          enabled = true;
          timeout = 900.0;
        };
      };

      idle.behavior_order = [
        "lock"
        "screen-off"
        "lock-and-suspend"
      ];

      # Sends a request to noctalia.dev to acquare the WAN-IP
      location.auto_locate = true;

      lockscreen = {
        allow_empty_password = true;
        blurred_desktop = true;
        fingerprint = false;
      };

      lockscreen_widgets = {
        enabled = true;
        schema_version = 2;
        grid = {
          cell_size = 8;
          major_interval = 4;
          visible = true;
        };

        widget_order = [
          "lock-login-winit"
          "lock-login-builtin-display"
          "lock-weather"
          "lock-audio-visualizer"
          "lock-media-player"
        ];

        widget = {
          lock-login-builtin-display = {
            box_height = 70.0;
            box_width = 400.0;
            cx = 960.0;
            cy = 600.0;
            output = "eDP-1";
            placement_height = 1200.0;
            placement_width = 1920.0;
            rotation = 0.0;

            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.97;
              background_radius = 12.0;
              center_password_text = true;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "compact";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = false;
              show_unlock_hint = false;
              show_weather = true;
            };
          };

          lock-login-winit = {
            box_height = 196.0;
            box_width = 810.0;
            cx = 476.0;
            cy = 972.0;
            output = "winit";
            placement_height = 1154.0;
            placement_width = 951.0;
            rotation = 0.0;

            type = "login_box";
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              center_password_text = false;
              input_opacity = 1.0;
              input_radius = 6.0;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };
          };

          weather = {
            box_height = 0.0;
            box_width = 0.0;
            cx = 132.0;
            cy = 70.0;
            output = "eDP-1";
            placement_height = 1200.0;
            placement_width = 1920.0;
            rotation = 0.0;

            type = "weather";
            settings.show_forecast = false;
          };

          lock-audio-visualizer = {
            box_height = 48.0;
            box_width = 384.0;
            cx = 1696.0;
            cy = 48.0;
            output = "eDP-1";
            placement_height = 1200.0;
            placement_width = 1920.0;
            rotation = 0.0;

            type = "audio_visualizer";
            settings.bands = 32;
            settings.show_when_idle = true;
          };

          lock-media-player = {
            box_height = 160.0;
            box_width = 384.0;
            cx = 1696.0;
            cy = 156.0;
            output = "eDP-1";
            placement_height = 1200.0;
            placement_width = 1920.0;
            rotation = 0.0;

            type = "media_player";
          };
        };
      };

      # Grenzen überwinden
      notification.border = false;

      osd = {
        background_opacity = 0.97;
        border = false;
        position = "top_left";
        position_vertical = "top_left";
      };

      plugins.source = [
        {
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          name = "official";
        }
        {
          enabled = false;
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          name = "community";
        }
      ];

      shell = {
        button_borders = false;
        card_borders = false;
        input_borders = false;
        niri_overview_type_to_launch_enabled = true;
        password_style = "random";
        popup_borders = false;
        popup_shadows = false;
        launcher.categories = false;
        panel = {
          borders = false;
          control_center_position = "center";
          open_near_click_control_center = true;
          open_near_click_session = true;
          session_placement = "floating";
          session_position = "center";
          shadow = false;
          transparency_mode = "glass";
          wallpaper_placement = "floating";
        };
        screenshot.remember_last_region = true;
        shadow.alpha = 0.0;

        greeter_sync.auto_sync = true;
      };

      backdrop.enabled = true;
      theme = {
        mode = "dark";
        # builtin = "Catppuccin";
        # community_palette = "Catppuccin Mocha Pink";
        source = "wallpaper";
        wallpaper_scheme = "m3-tonal-spot";

        templates.community_ids = [ "zed" ];
        templates.builtin_ids = [
          "alacritty"
          "btop"
          "gtk3"
          "gtk4"
          "niri"
          "qt"
        ];
      };

      widget = {
        launcher = {
          custom_image = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64@2x/categories/nix-snowflake.svg";
          custom_image_colorize = true;
          scale = 2.0;
        };

        Spacer.length = 16;
        Spacer.type = "spacer";
        workspaces = {
          hide_when_empty = true;
          show_icons = false;
          style = "focus_hint";
        };

        media = {
          album_art_only = true;
          art_size = 32;
          hide_when_no_media = true;
          title_scroll = "on_hover";
        };

        clipboard.enabled = false;
        tray.drawer = true;

        # Hide labels where unnessecary
        brightness.show_label = false;
        network.show_label = false;
        volume.show_label = false;
      };
    };
  };

  modules.home.theme =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.noctalia.enable {
        programs.noctalia.settings.wallpaper = {
          directory = "${config.xdg.userDirs.pictures}/Wallpapers";
          automation.enabled = true;
          default.path = "${config.xdg.userDirs.pictures}/Wallpapers/01.png";
        };
      };
    };

  modules.home.sops =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.noctalia.enable {
        sops.secrets.mail.sopsFile = ./secrets.yaml;

        programs.noctalia.settings.calendar.account.contact_hanakretzer_de = {
          color = "primary";
          credential_source = "file";
          name = "Hana";
          password_file = config.sops.secrets.mail.path;
          provider = "custom";
          server_url = "https://dav.theless.one/";
          type = "caldav";
          username = "contact@hanakretzer.de";
        };
      };
    };

  modules.home.hana =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.noctalia.enable {
        programs.noctalia.settings.shell.avatar_path = withSystem pkgs.stdenv.hostPlatform.system (
          { config, ... }: config.legacyPackages.profile-pictures.hana
        );
      };
    };

  modules.home.bitwarden =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.noctalia.enable {
        programs.noctalia.settings.plugins.enabled = [ "noctalia/bitwarden" ];
      };
    };

  modules.home.firefox =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.programs.noctalia.enable {
        programs.noctalia.settings.shell.mpris.blacklist = [ "firefox" ];
      };
    };

  modules.nixos.hardware =
    { lib, config, ... }:

    let

      inherit (lib)
        mkIf
        any
        attrValues
        ;

      hasNoctaliaUsers = any (
        cfg:

        cfg.isNormalUser
        && config ? home-manager.users.${cfg.name}
        && config.home-manager.users.${cfg.name}.programs.noctalia.enable
      ) (attrValues config.users.users);
    in

    {
      config = mkIf (config.programs.noctalia.enable && hasNoctaliaUsers) {
        services.logind.settings.Login.HandleLidSwitch = "ignore";
        services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
      };
    };
}
