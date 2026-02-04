{
  services.pipewire.wireplumber.extraConfig."99-valve-index"."monitor.alsa.rules" = [
    {
      matches = [
        {
          # wpctl status -> wpctl inspect <id>
          "node.nick" = "HDMI 1";
          "media.class" = "Audio/Sink";
        }
      ];
      actions.update-props = {
        api.alsa.period-size = 4096;
        api.alsa.headroom = 32768;
      };
    }
  ];
}
