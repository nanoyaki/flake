{ pkgs, username, ... }:

{
  options.nanoflake.desktop.gnome = true;

  config = {
    services = {
      displayManager.gdm.enable = true;
      xserver.displayManager = {
        autoLogin.enable = true;
        autoLogin.user = username;
      };

      desktopManager.gnome.enable = true;
    };

    systemd.services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    environment.gnome.excludePackages = with pkgs; [
      orca
      evince
      geary
      gnome-disk-utility
      gnome-backgrounds
      gnome-tour
      gnome-user-docs
      baobab
      epiphany
      gnome-text-editor
      gnome-calculator
      gnome-calendar
      gnome-characters
      gnome-console
      gnome-contacts
      gnome-font-viewer
      gnome-logs
      gnome-maps
      gnome-music
      gnome-weather
      nautilus
      gnome-connections
      simple-scan
      snapshot
      totem
      yelp
      gnome-software
    ];

    environment.systemPackages = [ pkgs.dolphin ];
  };
}
