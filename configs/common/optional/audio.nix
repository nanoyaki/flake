{
  lib,
  config,
  username,
  ...
}:

let
  inherit (lib) mkOption types;

  cfg = config.nanoflake.audio;
in

{
  options.nanoflake.audio = {
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
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;

      extraConfig = {
        pipewire."92-low-latency" = {
          "context.properties" = {
            "default.allowed-rates" = [ cfg.samplingRate ];
            "default.clock.rate" = cfg.samplingRate;
            "default.clock.quantum" = cfg.latency;
            "default.clock.min-quantum" = cfg.latency;
            "default.clock.max-quantum" = cfg.latency;
          };
        };

        pipewire-pulse."92-low-latency"."stream.properties"."node.latency" =
          "${toString cfg.latency}/${toString cfg.samplingRate}";
      };

      wireplumber.enable = true;
      wireplumber.extraConfig."92-low-latency" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                # wpctl status -> wpctl inspect <id>
                "node.name" = "~alsa_output.*";
              }
            ];
            "actions.update-props" = {
              "audio.rate" = cfg.samplingRate * 2;
              "api.alsa.period-size" = cfg.latency;
            };
          }
        ];
      };
    };

    users.users.${username}.extraGroups = [
      "jackaudio"
      "audio"
    ];
  };
}
