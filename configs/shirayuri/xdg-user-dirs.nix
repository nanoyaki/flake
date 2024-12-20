{ config, ... }:

let
  inherit (config.hm.lib.file) mkOutOfStoreSymlink;
in

{
  hm = {
    home.file = {
      # Link several default directories to directories
      # from the shared-with-windows NTFS drive
      "Downloads".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Downloads";
      "Documents".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Documents";
      "Videos".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Videos";
      "Pictures".source = mkOutOfStoreSymlink "/mnt/1TB-SSD/Pictures";

      # The drives themselves
      "Windows".source = mkOutOfStoreSymlink "/mnt/Windows";
      "1TB-SSD".source = mkOutOfStoreSymlink "/mnt/1TB-SSD";
    };

    xdg.userDirs = {
      enable = true;

      desktop = "/home/hana/Desktop";
      download = "/mnt/1TB-SSD/Downloads";
      documents = "/mnt/1TB-SSD/Documents";
      videos = "/mnt/1TB-SSD/Videos";
      pictures = "/mnt/1TB-SSD/Pictures";

      publicShare = null;
      templates = null;
      music = null;
    };
  };
}
