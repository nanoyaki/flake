{
  lib,
  lib',
  config,
  ...
}:

let
  inherit (lib) mkIf singleton;
in

{
  options.config'.theming.gtk.enable = lib'.options.mkFalseOption;

  config = mkIf config.config'.theming.gtk.enable {
    hms = singleton (
      { config, ... }:

      {
        gtk = rec {
          enable = true;

          gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
          gtk2.extraConfig = ''
            gtk-application-prefer-dark-theme="true"
          '';

          gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = true;
            gtk-menu-images = true;
            gtk-primary-button-warps-slider = true;
            gtk-toolbar-style = 3;
            gtk-decoration-layout = ":minimize,maximize,close";
            # gtk-enable-animations = false;
          };

          gtk4 = { inherit (gtk3) extraConfig; };
        };
      }
    );
  };
}
