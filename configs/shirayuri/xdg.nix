{
  pkgs,
  username,
  ...
}:

let
  dirConfig = {
    user = username;
    group = "users";
    mode = "0774";
  };
in

{
  hm = {
    home.symlinks = {
      # Link several xdg user directories to
      # directories on the os-shared btrfs drive
      Downloads = "/mnt/os-shared/Downloads";
      Documents = "/mnt/os-shared/Documents";
      Videos = "/mnt/os-shared/Videos";
      Pictures = "/mnt/os-shared/Pictures";
      Music = "/mnt/os-shared/Music";

      os-shared = "/mnt/os-shared";
    };

    xdg.userDirs = {
      enable = true;

      desktop = "/home/hana/Desktop";
      download = "/mnt/os-shared/Downloads";
      documents = "/mnt/os-shared/Documents";
      videos = "/mnt/os-shared/Videos";
      pictures = "/mnt/os-shared/Pictures";
      music = "/mnt/os-shared/Music";

      publicShare = null;
      templates = null;
    };

    xdg.desktopEntries.windows = {
      name = "Windows";
      comment = "Reboot to Windows";
      exec = "sudo systemctl reboot --boot-loader-entry=auto-windows";
      icon = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/apps/windows95.svg";
      categories = [ "System" ];
      terminal = false;
    };
  };

  systemd.tmpfiles.settings."10-os-shared-xdg-user-dirs" = {
    "/mnt/os-shared/Downloads".d = dirConfig;
    "/mnt/os-shared/Documents".d = dirConfig;
    "/mnt/os-shared/Videos".d = dirConfig;
    "/mnt/os-shared/Pictures".d = dirConfig;
    "/mnt/os-shared/Music".d = dirConfig;
  };
}
