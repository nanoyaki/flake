{
  config,
  ...
}:

let
  dirConfig = {
    user = config.config'.mainUserName;
    group = "users";
    mode = "0774";
  };
in

{
  hm.home.symlinks = {
    # Link several xdg user directories to
    # directories on the os-shared btrfs drive
    Downloads = "/mnt/os-shared/Downloads";
    Documents = "/mnt/os-shared/Documents";
    Videos = "/mnt/os-shared/Videos";
    Pictures = "/mnt/os-shared/Pictures";
    Music = "/mnt/os-shared/Music";

    os-shared = "/mnt/os-shared";
  };

  hm.xdg.userDirs = {
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

  systemd.tmpfiles.settings."10-os-shared-xdg-user-dirs" = {
    "/mnt/os-shared/Downloads".d = dirConfig;
    "/mnt/os-shared/Documents".d = dirConfig;
    "/mnt/os-shared/Videos".d = dirConfig;
    "/mnt/os-shared/Pictures".d = dirConfig;
    "/mnt/os-shared/Music".d = dirConfig;
  };
}
