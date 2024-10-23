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
        pulse.enable = true;
        jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        # media-session.enable = true;
        wireplumber.enable = true;
        extraConfig.pipewire."92-low-latency" = {
          context.properties = {
            default.clock.rate = samplingRate;
            default.allowed-rates = [ samplingRate ];
            default.clock.quantum = latency;
            default.clock.min-quantum = latency;
            default.clock.max-quantum = latency;
          };
        };

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

        wireplumber.configPackages = [
          (pkgs.writeTextDir "share/wireplumber/main.lua.d/92-low-latency.lua" ''
            alsa_monitor.rules = {
              {
                matches = {{{ "node.name", "matches", "alsa_output.*" }}};
                apply_properties = {
                  ["audio.format"] = "S32LE",
                  ["audio.rate"] = "${toString (samplingRate * 2)}",
                  ["api.alsa.period-size"] = ${toString latency}, -- defaults to 1024, tweak by trial-and-error
                },
              },
            }
          '')
        ];
      };

      environment.sessionVariables.PIPEWIRE_LATENCY = "${toString latency}/${toString samplingRate}";

      environment.systemPackages = with pkgs; [
        alsa-scarlett-gui
        reaper
        helvum
      ];
    };
}
