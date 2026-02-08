{
  flake.nixosModules.shirayuri-backups.services.borgbackup.jobs.system = {
    paths = "/";
    repo = "/mnt/os-shared/backups/system";
    doInit = true;

    patterns = [
      "+ /var/lib/sbctl"

      "+ /home/hana/Documents"
      "+ /home/hana/Pictures"
      "+ /home/hana/Desktop"
      "+ /home/hana/Music"
      "+ /home/hana/Videos"
      "+ /home/hana/.config"
      "+ /home/hana/.local/share/dolphin-emu"

      "+ /mnt/os-shared/VRChatProjects"
      "+ /mnt/os-shared/VRChat"
      "+ /mnt/os-shared/DolphinGames"
      "+ /mnt/os-shared/Games"
      "- **"
    ];

    encryption.mode = "none";
    compression = "auto,lzma";

    startAt = "daily";
    persistentTimer = true;
    prune.keep = {
      within = "1d";
      daily = 14;
      weekly = 12;
      monthly = -1;
    };
  };
}
