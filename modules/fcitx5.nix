{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.fcitx5 ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.fcitx5 ];
  };

  # TODO: look into i18n.inputMethod.fcitx5.quickPhrase
  modules.nixos.fcitx5 =
    { pkgs, ... }:

    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";

        fcitx5.addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];

        fcitx5.settings.inputMethod = {
          GroupOrder."0" = "Default";
          GroupOrder."1" = "Japanese";

          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "de";
            DefaultIM = "keyboard-de";
          };

          "Groups/0/Items/0".Name = "keyboard-de";
          "Groups/0/Items/0".Layout = "de";

          "Groups/1" = {
            Name = "Japanese";
            "Default Layout" = "de";
            DefaultIM = "mozc";
          };

          "Groups/1/Items/0".Name = "mozc";
          "Groups/1/Items/0".Layout = "de";
        };
      };
    };

  modules.nixos.niri =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf (config.i18n.inputMethod.enable && config.i18n.inputMethod.type == "fcitx5") {
        i18n.inputMethod.fcitx5.waylandFrontend = true;
      };
    };
}
