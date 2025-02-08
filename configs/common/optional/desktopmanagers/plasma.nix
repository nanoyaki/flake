{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
  cfg = config.nanoflake.desktop.plasma6;
in

{
  options.nanoflake.desktop.plasma6 = {
    enableWaylandDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Set Wayland as the default session";
    };

    withKdeConnect = mkEnableOption "KDE connect";
  };

  config = {
    services.desktopManager.plasma6.enable = true;
    programs.kdeconnect.enable = cfg.withKdeConnect;
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

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = [ "kde" ];
    };

    hm.xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = [ "kde" ];
    };

    environment.sessionVariables = {
      GTK_USE_PORTAL = "1";
      NIXOS_OZONE_WL = lib.optionalString cfg.enableWaylandDefault "1";
    };
  };
}
