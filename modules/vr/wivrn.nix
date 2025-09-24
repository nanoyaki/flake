{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib'.options) mkFalseOption;
  inherit (lib) mkIf;

  cfg = config.config'.wivrn;
in

{
  options.config'.wivrn.enable = mkFalseOption;

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable && (!config.config'.monado.enable);
        message = "Monado and WiVRn modules don't work at the same time";
      }
    ];

    hm.xdg.configFile."openxr/1/active_runtime.json".source =
      "${config.services.wivrn.package}/share/openxr/1/openxr_wivrn.json";

    environment.systemPackages = [ pkgs.monado-vulkan-layers ];
    hardware.graphics.extraPackages = [ pkgs.monado-vulkan-layers ];

    services.wivrn = {
      enable = true;
      openFirewall = true;

      # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
      # will automatically read this and work with WiVRn (Note: This does not currently
      # apply for games run in Valve's Proton)
      defaultRuntime = true;
      autoStart = false;

      # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
      config = {
        enable = true;
        json.tcp_only = false;
      };
    };
  };
}
