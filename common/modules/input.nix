{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  cfg = config.modules.input;
  inherit (lib) mkIf mkOption types;
in

{
  options.modules.input = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom input options.";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.imports = [ ./home/input.nix ];

    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      fcitx5.waylandFrontend = true;
    };

    services.libinput.mouse.accelProfile = "flat";

    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };
  };
}
