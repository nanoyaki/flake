{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.modules.plasma6;
in

{
  options.modules.plasma6.enableWaylandDefault = mkOption {
    type = types.bool;
    default = true;
    description = "Set Wayland as the default session.";
  };

  config = {
    services.desktopManager.plasma6.enable = true;
    programs.kdeconnect.enable = false;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      kate
      elisa
      kwrited
      ark
      okular
      print-manager
    ];

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = cfg.enableWaylandDefault;
      };

      autoLogin = {
        enable = true;
        user = username;
      };

      defaultSession = mkIf cfg.enableWaylandDefault "plasma";
    };

    environment.sessionVariables = mkIf cfg.enableWaylandDefault {
      NIXOS_OZONE_WL = "1";
    };
  };
}
