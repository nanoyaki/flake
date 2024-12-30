{ pkgs, config, ... }:

{
  hm.xdg.configFile."openxr/1/active_runtime.json".source =
    "${config.services.wivrn.package}/share/openxr/1/openxr_wivrn.json";

  environment.systemPackages = [ pkgs.monado-vulkan-layers ];

  services.wivrn = {
    enable = true;
    openFirewall = true;
    package = pkgs.wivrn;

    # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
    # will automatically read this and work with WiVRn (Note: This does not currently
    # apply for games run in Valve's Proton)
    defaultRuntime = true;
    autoStart = false;

    # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
    config = {
      enable = true;
      json = {
        # 1.0x foveation scaling
        scale = 1;
        # 300 Mb/s
        bitrate = 300000000;
        encoders = [
          {
            encoder = "nvenc";
            codec = "h265";
            # 1.0 x 1.0 scaling
            width = 1.0;
            height = 1.0;
            offset_x = 0.0;
            offset_y = 0.0;
          }
        ];
        tcp_only = false;
      };
    };
  };
}
