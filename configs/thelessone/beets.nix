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

  inherit (config.config'.lab-config.arr) group;
  user = "beets";
  configDir = "/var/lib/beets";
  package =
    (pkgs.beets.overrideAttrs (prevAttrs: {
      disabledTestPaths = prevAttrs.disabledTestPaths ++ [ "test/plugins/test_embedart.py" ];
    })).override
      {
        pluginOverrides.drop2beets = {
          enable = true;
          propagatedBuildInputs = [ pkgs.drop2beets ];
          wrapperBins = with pkgs; [ inotify-tools ];
        };
      };

  mediaDir = "${config.config'.lab-config.arr.home}/libraries/music";
  nzbPath = "${config.config'.lab-config.arr.home}/downloads/beets";
  torrentPath = "${config.config'.lab-config.arr.home}/downloads/transmission/complete/beets";

  beetsConfig = importPath: {
    directory = mediaDir;
    library = "${configDir}/library.blb";

    import = {
      write = true;
      copy = false;
      move = true;
      resume = false;
      group_albums = true;
      # quiet =
      # "no"; # Set by systemd, so that we can see logs if executed by hand
      quiet_fallback = "skip";
      log = "/var/log/beets.log";
    };

    item_fields = {
      firstartist = ''
        import re
        return re.split(r', | &| and| feat', albumartist)[0]
      '';
      lidarrtitle = ''
        filename = [artist, album, track, title]
        invalid_entries = {"artist", "album", "track", "title"}
        return "_".join([str(ent) for ent in filename if ent and str(ent) not in invalid_entries])
      '';
    };

    paths = {
      default = "$firstartist/$album%aunique{}/$lidarrtitle";
      singleton = "$firstartist/No-Album/$lidarrtitle";
      comp = "Compilations/$album%aunique{}/$lidarrtitle";
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
      "inline"
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
        (mkIf config.config'.sabnzbd.enable "sabnzbd.service")
        (mkIf config.config'.transmission.enable "transmission.service")
      ];

      environment.BEETSDIR = configDir;

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        ExecStart = "${getExe package} -c ${configFile} dropbox ${path}";

        User = user;
        Group = group;
        StateDirectory = configDir;
      };
    };
in
{

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "beet" ''${getExe package} -c ${
      (pkgs.formats.yaml { }).generate "config.yaml" (beetsConfig nzbPath)
    } "$@"'')
  ];

  users.users.beets = {
    isSystemUser = true;
    home = configDir;
    inherit group;
  };

  systemd.tmpfiles.rules = [
    "d '${configDir}'  0700 ${user} ${group} - -"
    "f '${configDir}/library.db'  0660 ${user} ${group} - -"
    "f '/var/log/beets.log'  0660 ${user} ${group} - -"
    "f '/var/log/drop2beets.log'  0660 ${user} ${group} - -"

    (mkIf config.config'.sabnzbd.enable "d '${nzbPath}' 2770 ${config.services.sabnzbd.user} ${group} - -")
    (mkIf config.config'.transmission.enable "d '${torrentPath}' 2770 ${config.services.transmission.user} ${group} - -")
  ];

  systemd.services = mkMerge [
    (mkIf config.config'.sabnzbd.enable {
      beets-import-nzb = serviceConfig { path = nzbPath; };
    })
    (mkIf config.config'.transmission.enable {
      beets-import-torrent = serviceConfig {
        path = torrentPath;
        override = {
          import = {
            copy = true;
            move = false;
          };
        };
      };
    })
  ];

  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          kaleido = pyPrev.kaleido.overridePythonAttrs rec {
            version = "1.0.0";
            format = null;
            pyproject = true;

            src = final.fetchFromGitHub {
              owner = "plotly";
              repo = "Kaleido";
              tag = "v${version}";
              hash = "sha256-yzzyLb5mS6laK/IutjNT6/bFFR7lGCRwatyAFBZhfmE=";
            };
            sourceRoot = "${src.name}/src/py";

            patches = [
              (final.replaceVars ./chromium.patch {
                chromium = lib.getExe final.chromium;
              })
            ];

            postPatch = ''
              substituteInPlace pyproject.toml \
                --replace-fail ', "setuptools-git-versioning"' "" \
                --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
            '';

            build-system = with pyFinal; [
              setuptools
              wheel
            ];

            dependencies = with pyFinal; [
              choreographer
              logistro
              orjson
              packaging
            ];

            postInstall = "";
          };

          choreographer = pyFinal.buildPythonPackage rec {
            pname = "choreographer";
            version = "1.0.10";
            pyproject = true;

            src = final.fetchFromGitHub {
              owner = "plotly";
              repo = "choreographer";
              tag = "v${version}";
              hash = "sha256-SAVbSVpz02ST3lmEpIqFgYF3ks33Z1Kp42b/xBA808U=";
            };

            postPatch = ''
              substituteInPlace pyproject.toml \
                --replace-fail ', "setuptools-git-versioning"' "" \
                --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
            '';

            build-system = with pyFinal; [
              setuptools
              wheel
            ];

            nativeCheckInputs =
              (with pyFinal; [
                pytest
                pytest-asyncio
                pytest-xdist
                async-timeout
                numpy
                mypy
                simplejson
              ])
              ++ (with final; [
                poethepoet
              ]);

            dependencies = with pyFinal; [
              logistro
              simplejson
            ];
          };

          logistro = pyFinal.buildPythonPackage rec {
            pname = "logistro";
            version = "1.1.0";
            pyproject = true;

            src = final.fetchFromGitHub {
              owner = "geopozo";
              repo = "logistro";
              tag = "v${version}";
              hash = "sha256-53PQnGRdcXKH7lcHj15PY/pfbyyUos8tlRS5NM/O/ms=";
            };

            postPatch = ''
              substituteInPlace pyproject.toml \
                --replace-fail ', "setuptools-git-versioning"' "" \
                --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
            '';

            build-system = with pyFinal; [
              setuptools
              wheel
            ];

            nativeCheckInputs =
              (with pyFinal; [
                pytest-xdist
                pytest
                mypy
              ])
              ++ (with final; [
                poethepoet
              ]);
          };
        })
      ];

      poethepoet = prev.poethepoet.overridePythonAttrs (prevAttrs: rec {
        version = "0.37.0";

        src = final.fetchFromGitHub {
          owner = "nat-n";
          repo = "poethepoet";
          tag = "v${version}";
          hash = "sha256-49Q1fHz/c6nYMOGwX0hqk0VJGl82CCyqjpH/rReFops=";
        };

        dependencies = (prevAttrs.dependencies or [ ]) ++ [ final.python3Packages.pyyaml ];
      });
    })
  ];
}
