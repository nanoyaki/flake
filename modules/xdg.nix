{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.xdg ];
  };

  modules.nixos.xdg = {
    xdg = {
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
    { lib, pkgs, ... }:

    {
      xdg.portal = {
        enable = lib.mkDefault true;
        config.preferred = {
          default = [
            "gtk"
            "gnome"
            "oo7"
          ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "oo7";
        };
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
          oo7-portal
        ];
        configPackages = lib.mkForce [ ];
      };
    };
}
