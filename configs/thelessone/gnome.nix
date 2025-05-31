{ pkgs, username, ... }:

{
  services = {
    displayManager = {
      sddm.enable = false;

      autoLogin = {
        enable = true;
        user = username;
      };
    };

    displayManager.gdm.enable = true;
    xserver.desktopManager.gnome.enable = true;

    desktopManager.plasma6.enable = false;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    cheese
    gnome-music
    gnome-terminal
    gedit
    epiphany
    geary
    evince
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ];

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd = {
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
}
