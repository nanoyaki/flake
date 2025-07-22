{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mapAttrs;
  inherit (lib'.options) mkDefault mkIntOption;

  cfg = config.config'.audio;
in

{
  options.config'.audio = {
    latency = mkDefault 512 mkIntOption;
    samplingRate = mkDefault 48000 mkIntOption;
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
      wireplumber.extraConfig."90-defaults".monitor.alsa.rules = lib.singleton {
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
      };
    };

    users.users = mapAttrs (_: _: { extraGroups = [ "audio" ]; }) config.config'.users;
  };
}
