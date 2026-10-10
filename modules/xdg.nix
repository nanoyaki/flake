{ config, ... }:

let
  flakeCfg = config;
in

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.xdg ];
  };

  configurations.nixos.shirayuri = {
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

  configurations.home."hana@shirayuri" =
    { config, ... }:

    let
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in

    {
      imports = [ flakeCfg.modules.home.xdg ];

      home.file = {
        Downloads.source = mkOutOfStoreSymlink "/mnt/os-shared/Downloads";
        Documents.source = mkOutOfStoreSymlink "/mnt/os-shared/Documents";
        Videos.source = mkOutOfStoreSymlink "/mnt/os-shared/Videos";
        Pictures.source = mkOutOfStoreSymlink "/mnt/os-shared/Pictures";
        Music.source = mkOutOfStoreSymlink "/mnt/os-shared/Music";
      };

      xdg.userDirs = {
        setSessionVariables = false;

        desktop = "/home/hana/Desktop";
        download = "/mnt/os-shared/Downloads";
        documents = "/mnt/os-shared/Documents";
        videos = "/mnt/os-shared/Videos";
        pictures = "/mnt/os-shared/Pictures";
        music = "/mnt/os-shared/Music";
        publicShare = null;
        templates = null;
      };
    };

  modules.home.xdg = _: {
    xdg = {
      enable = true;
      autostart.enable = true;
      mime.enable = true;
      mimeApps.enable = true;
      terminal-exec.enable = true;
      userDirs.enable = true;
    };
  };

  modules.home.niri =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf mkDefault;
    in

    {
      config = mkIf config.xdg.enable {
        xdg.portal = {
          enable = mkDefault true;
          xdgOpenUsePortal = mkDefault true;
          config.niri = {
            default = [
              "gnome"
              "gtk"
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

  modules.nixos.niri =
    {
      lib,
      pkgs,
      options,
      config,
      ...
    }:

    let
      inherit (lib) mkIf mkDefault mkForce;
    in

    {
      config = mkIf ((options.xdg ? enable) && config.xdg.enable) {
        xdg.portal = {
          enable = mkDefault true;
          xdgOpenUsePortal = mkDefault true;
          config.niri = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.Access" = "gtk";
            "org.freedesktop.impl.portal.Notification" = "gtk";
          };
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ];
          configPackages = mkForce [ ];
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

  modules.home.oo7 =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf optionalAttrs;
    in

    {
      config = mkIf config.xdg.enable {
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
