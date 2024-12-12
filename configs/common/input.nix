{
  pkgs,
  config,
  username,
  ...
}:

{
  users.users.${username}.extraGroups = [
    "input"
    "uinput"
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.fcitx5-mozc
      ];
      waylandFrontend =
        config.services.xserver.displayManager.gdm.wayland || config.modules.plasma6.enableWaylandDefault;
      plasma6Support = config.services.desktopManager.plasma6.enable;
    };
  };

  services.xserver = {
    desktopManager.runXdgAutostartIfNone = true;

    xkb = {
      layout = "de";
      variant = "";
    };
  };

  services.libinput.mouse.accelProfile = "flat";

  console.keyMap = "de";
}
