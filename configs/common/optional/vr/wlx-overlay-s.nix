{
  lib,
  pkgs,
  config,
  ...
}:

let
  getIndexId = pkgs.writeShellScript "getIndexId" ''
    ${lib.getExe' pkgs.pulseaudio "pactl"} list short sinks \
    | ${lib.getExe pkgs.gnugrep} hdmi-stereo-extra1 \
    | ${lib.getExe pkgs.gnused} -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,'
  '';

  setIndexVolume =
    volume:
    pkgs.writeShellScript "setIndexVolume" ''
      ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume $(${getIndexId}) ${volume}%
    '';
in

{
  systemd.user.services.wlx-overlay-s =
    {
      description = "wlx-overlay-s service";

      unitConfig.ConditionUser = "!root";

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.wlx-overlay-s} --openxr";
        Restart = "on-failure";
        Type = "simple";
      };

      environment = {
        OXR_VIEWPORT_SCALE_PERCENTAGE = "120";
        XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";
      };

      restartTriggers = [ pkgs.wlx-overlay-s ];
    }
    // lib.optionalAttrs config.services.monado.enable {
      environment.LIBMONADO_PATH = "${config.services.monado.package}/lib/libmonado.so";

      after = [ "monado.service" ];
      bindsTo = [ "monado.service" ];
      wantedBy = [ "monado.service" ];
      requires = [
        "monado.socket"
        "graphical-session.target"
      ];
    };

  hm.xdg.configFile."wlxoverlay/wayvr.yaml".source = (pkgs.formats.yaml { }).generate "wayvr.yaml" {
    version = 1;
    run_compositor_at_start = false;

    auto_hide = true;
    auto_hide_delay = 750;

    keyboard_repeat_delay = 200;
    keyboard_repeat_rate = 50;

    dashboard = {
      exec = lib.getExe pkgs.wayvr-dashboard;
      env = [ "GDK_BACKEND=wayland" ];
    };

    displays = {
      Watch = {
        width = 400;
        height = 600;
        scale = 0.4;
        attach_to = "HandRight";
        pos = [
          0.0
          0.0
          0.125
        ];
        rotation = {
          axis = [
            1.0
            0.0
            0.0
          ];
          angle = -45.0;
        };
      };

      Disp1 = {
        primary = true;
        width = 1920;
        height = 1080;
        scale = 1.0;
      };

      Disp2 = {
        width = 1920;
        height = 1080;
        scale = 1.0;
      };
    };

    catalogs.default_catalog.apps = [
      {
        name = "Btop";
        target_display = "Watch";
        exec = lib.getExe pkgs.btop;
      }
      {
        name = "Vesktop";
        target_display = "Disp2";
        exec = lib.getExe pkgs.vesktop;
      }
      {
        name = "Firefox";
        target_display = "Disp1";
        exec = lib.getExe pkgs.firefox;
      }
    ];
  };

  hm.xdg.configFile."wlxoverlay/watch.yaml".source = (pkgs.formats.yaml { }).generate "watch.yaml" {
    width = 0.115;

    size = [
      400
      200
    ];

    elements = [
      {
        type = "Panel";
        rect = [
          0
          30
          400
          130
        ];
        corner_radius = 20;
        bg_color = "#24273a";
      }
      {
        type = "Button";
        rect = [
          2
          162
          26
          36
        ];
        corner_radius = 4;
        font_size = 15;
        fg_color = "#24273a";
        bg_color = "#c6a0f6";
        text = "C";
        click_up = [
          {
            type = "Window";
            target = "settings";
            action = "ShowUi";
          }
          {
            type = "Window";
            target = "settings";
            action = "Destroy";
          }
        ];
      }
      {
        type = "Button";
        rect = [
          32
          162
          48
          36
        ];
        corner_radius = 4;
        font_size = 15;
        bg_color = "#2288FF";
        fg_color = "#24273a";
        text = "Dash";
        click_up = [
          {
            type = "WayVR";
            action = "ToggleDashboard";
          }
        ];
      }
      {
        type = "Button";
        rect = [
          84
          162
          48
          36
        ];
        corner_radius = 4;
        font_size = 15;
        bg_color = "#a6da95";
        fg_color = "#24273a";
        text = "Kbd";
        click_up = [
          {
            type = "Overlay";
            target = "kbd";
            action = "ToggleVisible";
          }
        ];
        long_click_up = [
          {
            type = "Overlay";
            target = "kbd";
            action = "Reset";
          }
        ];
        middle_up = [
          {
            type = "Overlay";
            target = "kbd";
            action = "ToggleInteraction";
          }
        ];
        right_up = [
          {
            type = "Overlay";
            target = "kbd";
            action = "ToggleImmovable";
          }
        ];
        scroll_down = [
          {
            type = "Overlay";
            target = "kbd";
            action = {
              Opacity = {
                delta = -0.025;
              };
            };
          }
        ];
        scroll_up = [
          {
            type = "Overlay";
            target = "kbd";
            action = {
              Opacity = {
                delta = 0.025;
              };
            };
          }
        ];
      }
      {
        type = "OverlayList";
        rect = [
          134
          160
          266
          40
        ];
        corner_radius = 4;
        font_size = 15;
        bg_color = "#1e2030";
        fg_color = "#cad3f5";
        layout = "Horizontal";
        click_up = "ToggleVisible";
        long_click_up = "Reset";
        right_up = "ToggleImmovable";
        middle_up = "ToggleInteraction";
        scroll_up.Opacity.delta = 0.025;
        scroll_down.Opacity.delta = -0.025;
      }
      {
        type = "Label";
        rect = [
          19
          90
          200
          50
        ];
        corner_radius = 4;
        font_size = 46;
        fg_color = "#cad3f5";
        source = "Clock";
        format = "%H:%M";
      }
      {
        type = "Label";
        rect = [
          20
          117
          200
          20
        ];
        corner_radius = 4;
        font_size = 14;
        fg_color = "#cad3f5";
        source = "Clock";
        format = "%x";
      }
      {
        type = "Label";
        rect = [
          20
          137
          200
          50
        ];
        corner_radius = 4;
        font_size = 14;
        fg_color = "#cad3f5";
        source = "Clock";
        format = "%A";
      }
      {
        type = "Label";
        rect = [
          210
          90
          200
          50
        ];
        corner_radius = 4;
        font_size = 24;
        fg_color = "#8bd5ca";
        source = "Clock";
        timezone = 0;
        format = "%H:%M";
      }
      {
        type = "Label";
        rect = [
          210
          60
          200
          50
        ];
        corner_radius = 4;
        font_size = 14;
        fg_color = "#8bd5ca";
        source = "Timezone";
        timezone = 0;
      }
      {
        type = "Label";
        rect = [
          210
          150
          200
          50
        ];
        corner_radius = 4;
        fg_color = "#b7bdf8";
        font_size = 24;
        source = "Clock";
        timezone = 1;
        format = "%H:%M";
      }
      {
        type = "Label";
        rect = [
          210
          120
          200
          50
        ];
        corner_radius = 4;
        font_size = 14;
        fg_color = "#b7bdf8";
        source = "Timezone";
        timezone = 1;
      }
      {
        type = "BatteryList";
        rect = [
          0
          5
          400
          30
        ];
        corner_radius = 4;
        font_size = 16;
        fg_color = "#8bd5ca";
        fg_color_low = "#B06060";
        fg_color_charging = "#6080A0";
        num_devices = 9;
        layout = "Horizontal";
        low_threshold = 33;
      }
      {
        type = "Button";
        rect = [
          315
          52
          70
          32
        ];
        corner_radius = 4;
        font_size = 13;
        fg_color = "#cad3f5";
        bg_color = "#5b6078";
        text = "Vol +";
        click_down = [
          {
            type = "Exec";
            command = [ "${setIndexVolume "+5"}" ];
          }
        ];
      }
      {
        type = "Button";
        rect = [
          315
          116
          70
          32
        ];
        corner_radius = 4;
        font_size = 13;
        fg_color = "#cad3f5";
        bg_color = "#5b6078";
        text = "Vol -";
        click_down = [
          {
            type = "Exec";
            command = [ "${setIndexVolume "-5"}" ];
          }
        ];
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    wlx-overlay-s
    wayvr-dashboard
  ];
}
