{
  lib,
  config,
  pkgs,
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
      description = "The latency to use for pipewire.";
    };

    samplingRate = mkOption {
      type = types.int;
      default = 48000; # 192000 48000 44100
      description = "The sampling rate to use for pipewire.";
    };
  };

  config =
    let
      latency = cfg.latency;
      samplingRate = cfg.samplingRate;
    in
    {
      # Enable sound with pipewire.
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        audio.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        jack.enable = true;

        extraConfig.pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = samplingRate;
            default.allowed-rates = [ samplingRate ];
            default.clock.quantum = latency;
            default.clock.min-quantum = latency;
            default.clock.max-quantum = latency;
          };
        };

        pulse.enable = true;
        extraConfig.pipewire-pulse."92-low-latency" = {
          context.modules = [
            {
              name = "libpipewire-module-protocol-pulse";
              args = {
                pulse.min.frag = "${toString latency}/${toString samplingRate}";
                pulse.min.req = "${toString latency}/${toString samplingRate}";
                pulse.default.req = "${toString latency}/${toString samplingRate}";
                pulse.max.req = "${toString latency}/${toString samplingRate}";
                pulse.min.quantum = "${toString latency}/${toString samplingRate}";
                pulse.max.quantum = "${toString latency}/${toString samplingRate}";
              };
            }
          ];

          stream.properties = {
            node.latency = "${toString latency}/${toString samplingRate}";
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
                    "audio.rate" = samplingRate * 2;
                    "api.alsa.period-size" = latency;
                  };
                };
              }
            ];
          };
        };
      };

      environment.systemPackages = with pkgs; [
        alsa-scarlett-gui
        reaper
        helvum
      ];
    };
}
