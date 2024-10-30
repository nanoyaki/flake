{
  lib,
  config,
  pkgs,
  username,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.modules.audio;
in

{
  options.modules.audio = {
    latency = mkOption {
      type = types.int;
      default = 512; # powers of 2
    };

    samplingRate = mkOption {
      type = types.int;
      default = 48000; # 192000 48000 44100
    };
  };

  config = {
    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;

      extraConfig.pipewire."92-low-latency" =
        let
          latency = cfg.latency;
          samplingRate = cfg.samplingRate;
        in
        {
          context.properties = {
            default.clock.rate = samplingRate;
            default.allowed-rates = [ samplingRate ];
            default.clock.quantum = latency;
            default.clock.min-quantum = latency;
            default.clock.max-quantum = latency;
          };
        };

      pulse.enable = true;
      extraConfig.pipewire-pulse."92-low-latency" =
        let
          latency = "${toString cfg.latency}/${toString cfg.samplingRate}";
        in
        {
          context.modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                "pulse.min.frag" = latency;
                "pulse.min.req" = latency;
                "pulse.default.req" = latency;
                "pulse.max.req" = latency;
                "pulse.min.quantum" = latency;
                "pulse.max.quantum" = latency;
              };
            }
          ];

          stream.properties = {
            "node.latency" = latency;
          };
        };

      wireplumber.enable = true;
      wireplumber.extraConfig = {
        "99-valve-index" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  # wpctl status -> wpctl inspect <id>
                  "object.path" = "alsa:acp:HDMI:5:playback";
                }
              ];
              actions = {
                update-props = {
                  "api.alsa.period-size" = 2048;
                  "api.alsa.headroom" = 8192;
                };
              };
            }
          ];
        };

        "92-low-latency" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  # wpctl status -> wpctl inspect <id>
                  "node.name" = "~alsa_output.*";
                }
              ];
              actions = {
                update-props = {
                  "audio.rate" = cfg.samplingRate * 2;
                  "api.alsa.period-size" = cfg.latency;
                };
              };
            }
          ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      reaper
      helvum
    ];

    users.users."${username}".extraGroups = [
      "jackaudio"
      "audio"
    ];
  };
}
