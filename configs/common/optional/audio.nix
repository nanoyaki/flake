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
              "audio.rate" = cfg.samplingRate;
              "api.alsa.period-size" = cfg.latency;
              "api.alsa.rate" = cfg.samplingRate;
            };
          }
        ];
      };
    };

    users.users.${username}.extraGroups = [ "audio" ];
  };
}
