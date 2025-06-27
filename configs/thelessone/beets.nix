{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    getExe
    mkIf
    mkMerge
    recursiveUpdate
    ;

  inherit (config.services'.lab-config.arr) group;
  user = "beets";
  configDir = "/var/lib/beets";
  package = pkgs.beets.override {
    pluginOverrides.drop2beets = {
      enable = true;
      propagatedBuildInputs = [ pkgs.drop2beets ];
      wrapperBins = [ pkgs.coreutils ];
    };
  };

  mediaDir = "${config.services'.lab-config.arr.home}/libraries/music";
  nzbPath = "${config.services'.lab-config.arr.home}/downloads/beets";
  torrentPath = "${config.services'.lab-config.arr.home}/downloads/transmission/complete/beets";

  beetsConfig = importPath: {
    directory = mediaDir;
    library = "${configDir}/library.blb";

    import = {
      write = true;
      copy = "no";
      move = "yes";
      resume = false;
      # quiet =
      # "no"; # Set by systemd, so that we can see logs if executed by hand
      quiet_fallback = "skip";
      log = "/var/log/beets.log";
    };

    paths = {
      default = "%asciify{$albumartist $album}[$year]/$track-$title}";
      singleton = "%asciify{Non-Album/$artist-$title[$year]}";
      comp = "%asciify{Compilations/$album/$track-$title}";
    };

    plugins = [
      "fetchart"
      "embedart"
      "fromfilename"
      "badfiles"
      "duplicates"
      "scrub"
      "web"
      "lyrics"
      "lastgenre"
      "drop2beets"
    ];
    art_filename = "folder";

    fetchart = {
      auto = true;
      minwidth = 0;
      maxwidth = 0;
      enforce_ratio = false;
      cautious = false;
      cover_names = [
        "cover"
        "front"
        "art"
      ];
      sources = [
        "filesystem"
        "coverart"
        "itunes"
        "amazon"
        "albumart"
      ];
    };

    embedart = {
      auto = true;
      remove_art_file = "no";
    };

    lyrics = {
      auto = "yes";
      sources = [
        "lrclib"
        "genius"
      ];
      synced = "yes";
    };

    lastgenre = {
      auto = "yes";
      count = 2;
    };

    drop2beets = {
      dropbox_path = importPath;
      log_path = "/var/log/drop2beets.log";
    };
  };

  serviceConfig =
    {
      path,
      override ? { },
    }:

    let
      finalConfig = recursiveUpdate (beetsConfig path) override;
      configFile = (pkgs.formats.yaml { }).generate "config.yaml" finalConfig;
    in

    {
      wantedBy = [ "multi-user.target" ];
      after = [
        "nfs-client.target"
        (mkIf config.services'.sabnzbd.enable "sabnzbd.service")
        (mkIf config.services'.transmission.enable "transmission.service")
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe package} -c ${configFile} install_dropbox";
        Restart = "on-failure";
        User = user;
        Group = group;
      };
    };
in
{
  environment.systemPackages = with pkgs; [
    beets
  ];

  users.users.${user} = {
    isSystemUser = true;
    inherit group;
  };

  systemd.tmpfiles.rules = [
    "d '${configDir}'  0770 ${user} ${group} - -"
    "f '${configDir}/library.db'  0660 ${user} ${group} - -"
    "f '/var/log/beets.log'  0660 ${user} ${group} - -"
    "f '/var/log/drop2beets.log'  0660 ${user} ${group} - -"

    (mkIf config.services'.sabnzbd.enable "d '${nzbPath}' 2770 ${config.services.sabnzbd.user} ${group} - -")
    (mkIf config.services'.transmission.enable "d '${torrentPath}' 2770 ${config.services.transmission.user} ${group} - -")
  ];

  systemd.services = mkMerge [
    (mkIf config.services'.sabnzbd.enable {
      beets-import-nzb = serviceConfig { path = nzbPath; };
    })
    (mkIf config.services'.transmission.enable {
      beets-import-torrent = serviceConfig {
        path = torrentPath;
        override = {
          import = {
            copy = "yes";
            move = "no";
          };
        };
      };
    })
  ];
}
