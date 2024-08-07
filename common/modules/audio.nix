{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.audio;
in {
  options.services.nano.audio = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable pipewire settings.";
    };

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

  config = let
    latency = cfg.latency;
    samplingRate = cfg.samplingRate;
  in (mkIf cfg.enable {
    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
      # wireplumber.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = samplingRate;
          default.allowed-rates = [samplingRate];
          default.clock.quantum = latency;
          default.clock.min-quantum = latency;
          default.clock.max-quantum = latency;
        };
      };

      extraConfig.pipewire.adjust-sample-rate = {
        "context.properties" = {
          "default.clock.rate" = samplingRate;
          "default.allowed-rates" = [samplingRate];
          "default.clock.quantum" = latency;
          "default.clock.min-quantum" = latency;
          "default.clock.max-quantum" = latency;
        };
      };

      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
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
    };

    environment.sessionVariables.PIPEWIRE_LATENCY = "${toString latency}/${toString samplingRate}";
  });
}
