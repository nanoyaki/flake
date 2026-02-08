{ withSystem, ... }:

{
  perSystem =
    { inputs', ... }:

    {
      packages.default-wallpaper = inputs'.nanopkgs.legacyPackages.fetchPixivIllust {
        pixivId = 140824539;
        hash = "sha256-MjEEnE6t4B2zhGE1oDCpMGGQO9rI97eFnhH4Nz4P9X0=";
      };
    };

  flake.overlays.wallpapers =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) default-wallpaper;
      }
    );

  flake.nixosModules.theme =
    { lib, config, ... }:

    {
      boot = {
        consoleLogLevel = lib.mkDefault 0;
        initrd.verbose = lib.mkDefault false;
        kernelParams = lib.mkDefault [
          "quiet"
          "boot.shell_on_fail"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=0"
          "udev.log_priority=0"
        ];

        plymouth.enable = lib.mkDefault true;
      };

      specialisation.verbose.configuration.boot = {
        consoleLogLevel = 4;
        initrd.verbose = true;
        kernelParams = [
          "boot.shell_on_fail"
          "rd.systemd.show_status=true"
        ];

        plymouth.enable = false;
      };

      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = if config.services.desktopManager.plasma6.enable then "Breeze" else "adw-gtk3-dark";
          };
        }
      ];

      qt = lib.mkIf config.services.desktopManager.cosmic.enable {
        enable = true;
        style = "adwaita-dark";
        platformTheme = "gnome";
      };
    };

  flake.homeModules.theme =
    { config, ... }:

    let
      gtk3Plus = {
        gtk-application-prefer-dark-theme = true;
        gtk-menu-images = true;
        gtk-primary-button-warps-slider = true;
        gtk-toolbar-style = 3;
        gtk-decoration-layout = ":minimize,maximize,close";
        # gtk-enable-animations = false;
      };
    in

    {
      gtk = {
        enable = true;
        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        gtk2.extraConfig = ''
          gtk-application-prefer-dark-theme="true"
        '';
        gtk3.extraConfig = gtk3Plus;
        gtk4.extraConfig = gtk3Plus;
      };
    };
}
