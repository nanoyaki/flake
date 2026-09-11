{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.audio ];
  };

  modules.nixos.audio =
    { lib, config, ... }:

    let
      inherit (lib) mkOption types;
      cfg = config.services.audio;
      powerOf2 = types.addCheck types.int (x: (builtins.bitAnd x (x - 1)) == 0);
    in

    {
      options.services.audio = {
        latency = mkOption {
          type = powerOf2;
          default = 512;
          description = ''
            Specifies the buffer size which plays a big
            part in audio latency. Lower values will lead
            to less latency but make audio more prone to
            crackling under CPU intensive tasks.
          '';
        };

        samplingRate = mkOption {
          type = types.enum [
            8000
            16000
            22050
            32000
            44100
            48000
            96000
            192000
          ];
          default = 48000;
          description = ''
            The audio sampling rate frequently also referred
            to as audio frequency.
          '';
        };
      };

      config = {
        services.pulseaudio.enable = false;
        services.pipewire = {
          enable = true;
          pulse.enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;

          wireplumber.enable = true;
          wireplumber.extraConfig."90-defaults".monitor.alsa.rules = [
            {
              matches = [
                {
                  # wpctl status -> wpctl inspect <id>
                  "media.class" = "Audio/Sink";
                }
              ];

              actions.update-props = with cfg; {
                audio.rate = samplingRate;
                api.alsa.rate = samplingRate;
                api.alsa.period-size = latency;
              };
            }
          ];
        };
      };
    };
}
