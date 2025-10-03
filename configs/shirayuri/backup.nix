{
  lib,
  pkgs,
  config,
  ...
}:

let
  defaults = {
    initialize = true;

    paths = [
      "/var/lib/sbctl"

      "/home/hana/Documents"
      "/home/hana/Pictures"
      "/home/hana/Desktop"
      "/home/hana/Music"
      "/home/hana/Videos"
      "/home/hana/.config"

      "/mnt/os-shared/VRChatProjects"
      "/mnt/os-shared/VRChat"
      "/mnt/os-shared/DolphinGames"
      "/mnt/os-shared/Games"
    ]
    ++ config.services.restic.extraPaths;

    environmentFile = "${pkgs.writeText "restic-env" "GOMAXPROCS=6"}";

    timerConfig = {
      # Every day at 3am
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 6"
      "--keep-yearly 2"
    ];
  };

  mkBackup = override: lib.recursiveUpdate defaults override;
in

{
  options.services.restic.extraPaths = pkgs.lib.nanolib.options.mkListOf pkgs.lib.nanolib.options.mkPathOption;

  config = {
    sops.secrets = {
      "backups/local" = { };
      "backups/nas" = { };
      "backups/nas-server" = { };
      # "backups/remote" = { };
      # "backups/remote-server" = { };
    };

    sops.templates."restic-nas-repo".content = ''
      rest:http://restic:${config.sops.placeholder."backups/nas-server"}@10.0.0.3:8000/shirayuri-nas
    '';

    # sops.templates."restic-remote-repo".content = ''
    #   rest:https://restic:${
    #     config.sops.placeholder."backups/remote-server"
    #   }@100.64.64.1:8123/shirayuri-remote
    # '';

    services.restic.backups = {
      local = mkBackup {
        repository = "/mnt/os-shared/backups/shirayuri";
        passwordFile = config.sops.secrets."backups/local".path;
      };

      nas = mkBackup {
        repositoryFile = config.sops.templates."restic-nas-repo".path;
        passwordFile = config.sops.secrets."backups/nas".path;
      };

      # Lets not for now... 60GiB using 28.8MiB/s takes too long
      # remote = mkBackup {
      #   repositoryFile = config.sops.templates."restic-remote-repo".path;
      #   passwordFile = config.sops.secrets."backups/remote".path;
      # };
    };
  };
}
