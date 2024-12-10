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
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
    fcitx5.waylandFrontend =
      config.services.xserver.displayManager.gdm.wayland || config.modules.plasma6.enableWaylandDefault;
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
