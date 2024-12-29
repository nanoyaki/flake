{ config, username, ... }:

let
  inherit (config.hm.lib.file) mkOutOfStoreSymlink;

  dirConfig = {
    user = username;
    group = "users";
    mode = "0774";
  };
in

{
  hm = {
    home.file = {
      # Link several default directories to directories
      # from the os-shared btrfs drive
      "Downloads".source = mkOutOfStoreSymlink "/mnt/os-shared/Downloads";
      "Documents".source = mkOutOfStoreSymlink "/mnt/os-shared/Documents";
      "Videos".source = mkOutOfStoreSymlink "/mnt/os-shared/Videos";
      "Pictures".source = mkOutOfStoreSymlink "/mnt/os-shared/Pictures";

      "os-shared".source = mkOutOfStoreSymlink "/mnt/os-shared";
    };

    xdg.userDirs = {
      enable = true;

      desktop = "/home/hana/Desktop";
      download = "/mnt/os-shared/Downloads";
      documents = "/mnt/os-shared/Documents";
      videos = "/mnt/os-shared/Videos";
      pictures = "/mnt/os-shared/Pictures";

      publicShare = null;
      templates = null;
      music = null;
    };
  };

  systemd.tmpfiles.settings."10-os-shared-xdg-user-dirs" = {
    "Downloads".d = dirConfig;
    "Documents".d = dirConfig;
    "Videos".d = dirConfig;
    "Pictures".d = dirConfig;
  };
}
