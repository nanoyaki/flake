{
  flake.nixosModules.fcitx5 =
    { pkgs, config, ... }:

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
            config.services.displayManager.gdm.wayland
            || config.services.desktopManager.plasma6.enable
            || config.services.desktopManager.cosmic.enable;

          settings.inputMethod = {
            GroupOrder = {
              "0" = "Default";
              "1" = "Japanese";
            };

            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "de";
              DefaultIM = "keyboard-de";
            };
            "Groups/0/Items/0" = {
              Name = "keyboard-de";
              Layout = "de";
            };

            "Groups/1" = {
              Name = "Japanese";
              "Default Layout" = "de";
              DefaultIM = "mozc";
            };
            "Groups/1/Items/0" = {
              Name = "mozc";
              Layout = "de";
            };
          };
        };
      };
    };

  # TODO: look into i18n.inputMethod.fcitx5.quickPhrase
}
