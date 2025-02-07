{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  cfg = config.nanoflake.keyboard;
in

{
  options.nanoflake.keyboard = {
    layout = lib.mkOption {
      type = lib.types.str;
      default = "de";
      example = "at";
      description = "Sets the xkb and tty keyboard layout";
    };

    variant = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "dvorak";
      description = "Sets the xkb keyboard layout variant";
    };
  };

  config = {
    users.users.${username}.extraGroups = [
      "input"
      "uinput"
    ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
        waylandFrontend =
          config.services.xserver.displayManager.gdm.wayland || config.nanoflake.plasma6.enableWaylandDefault;
      };
    };

    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    services.libinput.mouse.accelProfile = "flat";
    services.xserver.xkb = { inherit (cfg) layout variant; };
    console.keyMap = cfg.layout;
  };
}
