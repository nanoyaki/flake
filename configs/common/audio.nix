{
  lib,
  config,
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
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;

      extraConfig.pipewire."92-low-latency" = {
        context.properties = {
          "default.allowed-rates" = [ cfg.samplingRate ];
          "default.clock.rate" = cfg.samplingRate;
          "default.clock.quantum" = cfg.latency;
          "default.clock.min-quantum" = cfg.latency;
          "default.clock.max-quantum" = cfg.latency;
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
      wireplumber.extraConfig."92-low-latency" = {
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

    users.users."${username}".extraGroups = [
      "jackaudio"
      "audio"
    ];
  };
}
