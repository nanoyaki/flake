{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib'.options) mkFalseOption;
  inherit (lib) mkIf mkMerge;

  cfg = config.config'.noCosmic;
in

{
  options.config'.noCosmic = mkFalseOption;

  config = mkMerge [
    (mkIf (!cfg) {
      services.desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };

      environment.cosmic.excludePackages = [ pkgs.cosmic-term ];

      services.displayManager = {
        cosmic-greeter.enable = true;
        defaultSession = "cosmic";
      };

      xdg.portal.xdgOpenUsePortal = true;
      hms = lib.singleton {
        xdg.portal = removeAttrs config.xdg.portal [
          "gtkUsePortal"
          "lxqt"
          "wlr"
        ];
      };
    })
    {
      services.displayManager.autoLogin = {
        enable = true;
        user = config.config'.mainUserName;
      };

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        GDK_BACKEND = "wayland";
      };
    }
  ];
}
