{
  pkgs,
  config,
  ...
}:

let
  cfg = config.config'.keyboard;
in

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      waylandFrontend =
        config.services.displayManager.gdm.wayland || config.services.desktopManager.plasma6.enable;
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = cfg.layout;
          DefaultIM = "keyboard-${cfg.layout}";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-${cfg.layout}";
          Layout = cfg.layout;
        };
      };
    };
  };

  services = {
    libinput.mouse.accelProfile = "flat";
    xserver.desktopManager.runXdgAutostartIfNone = true;
    xserver.xkb = cfg;
  };
}
