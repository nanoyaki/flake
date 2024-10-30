{
  pkgs,
  ...
}:

{
  hm.i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
    fcitx5.waylandFrontend = true;
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  services.libinput.mouse.accelProfile = "flat";

  console.keyMap = "de";
}
