{
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib'.options) mkFalseOption;

  cfg = config.config'.keyboard;
in

{
  options.config'.keyboard.fcitx5.enable = mkFalseOption;

  config = {
    i18n.inputMethod = {
      inherit (cfg.fcitx5) enable;
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
      xserver.desktopManager.runXdgAutostartIfNone = cfg.fcitx5.enable;
      xserver.xkb = cfg;
    };
  };
}
