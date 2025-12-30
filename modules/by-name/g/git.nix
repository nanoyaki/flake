{
  lib,
  pkgs,
  config,
  ...
}:

let
  gpgKey = pkgs.fetchurl {
    url = "https://github.com/nanoyaki.gpg";
    hash = "sha256-LTdGeydh1xxkiaI1EkP+BWaOo/1pw7SL82E2svO2H+A=";
  };

  fingerprint = "5A1DC7CE51DC0A856DEA41F731A8CE0D2E7D30C3";

  convCommit = conv: ''
    !f() { \
      scope="$1"; msg="$2"; breaking=""; \
      [[ $scope == *! ]] && breaking="!" && scope="''${scope%!}"; \
      if [ -n "$msg" ]; then \
        git commit -m "${conv}($scope)$breaking: $msg"; \
      else \
        git commit -m "${conv}$breaking: $scope"; \
      fi; \
    }; f \
  '';
in

{
  hm = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };

    programs.git = {
      settings = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        fetch.all = true;
        pull.autoStash = true;
        pull.rebase = true;
        rebase.autoStash = true;

        lfs."https://git.theless.one/".locksverify = true;

        alias = {
          rv = "remote -v";
          rb = "rebase";
          rbi = "rebase -i";
          co = "checkout -b";
          cor = ''!f() { git checkout -B "$1" "''${2:-"origin"}/$1"; }; f'';
          d = ''!f() { git diff "''${@:-"HEAD"}"; }; f'';

          fix = convCommit "fix";
          feat = convCommit "feat";
          chore = convCommit "chore";
        };

        user = {
          email = "hanakretzer@nanoyaki.space";
          name = "nanoyaki";
        };
      };

      signing = {
        key = fingerprint;
        format = "openpgp";
        signByDefault = true;
      };
    };

    programs.gpg.settings.default-key = fingerprint;

    home.activation.import-gpg-key = config.hm.lib.dag.entryAfter [ "writeBoundary" ] ''
      run ${lib.getExe pkgs.gnupg} --list-keys "${fingerprint}" >/dev/null 2>&1 \
        || ${lib.getExe pkgs.gnupg} $VERBOSE_ARG --import "${gpgKey}"
    '';
  };

  programs.git.config = lib.recursiveUpdate config.hm.programs.git.settings {
    core.pager = lib.getExe config.hm.programs.delta.package;
    interactive.diffFilter = "${lib.getExe config.hm.programs.delta.package} --color-only";
    delta = config.hm.programs.delta.options;

    user.signingKey = fingerprint;
    gpg.format = "openpgp";
    gpg.openpgp.program = lib.getExe pkgs.gnupg;
    commit.gpgSign = true;
    tag.gpgSign = true;
  };
}
