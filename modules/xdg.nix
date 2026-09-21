{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.xdg ];
  };

  modules.nixos.xdg =
    { lib, ... }:

    let
      inherit (lib) mkEnableOption;
    in

    {
      options.xdg.enable = mkEnableOption "xdg" // {
        default = true;
      };

      config.xdg = {
        autostart.enable = true;
        mime.enable = true;
        terminal-exec.enable = true;
        icons.enable = true;
        menus.enable = true;
        sounds.enable = true;
      };
    };

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.xdg ];
  };

  modules.home.xdg = {
    xdg = {
      enable = true;
      autostart.enable = true;
      mime.enable = true;
      mimeApps.enable = true;
      terminal-exec.enable = true;
    };
  };

  modules.nixos.niri =
    {
      lib,
      pkgs,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf ((options.xdg ? enable) && config.xdg.enable) {
        xdg.portal = {
          enable = lib.mkDefault true;
          config.niri = {
            default = [
              "gtk"
              "gnome"
            ];
            "org.freedesktop.impl.portal.Access" = "gtk";
            "org.freedesktop.impl.portal.Notification" = "gtk";
          };
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ];
          configPackages = lib.mkForce [ ];
        };
      };
    };

  modules.nixos.oo7 =
    {
      lib,
      pkgs,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf optionalAttrs;
    in

    {
      config = mkIf ((options.xdg ? enable) && config.xdg.enable) {
        xdg.portal.extraPortals = [ pkgs.oo7-portal ];
        xdg.portal.config = {
          common."org.freedesktop.impl.portal.Secret" = "oo7";
        }
        // optionalAttrs config.programs.niri.enable {
          niri."org.freedesktop.impl.portal.Secret" = "oo7";
        };
      };
    };
}
