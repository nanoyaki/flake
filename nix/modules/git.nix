let
  # Goodbye PGP: https://gpg.fail/

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

  common = {
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    pull.autoStash = true;
    pull.rebase = true;
    rebase.autoStash = true;

    lfs."https://git.theless.one/".locksverify = true;

    alias = {
      rv = "remote -v";
      rb = "rebase";
      rbi = "rebase -i";
      co = ''!f() { git checkout "$1" 2>/dev/null || git checkout -b "$1"; }; f'';
      cor = ''!f() { git checkout -B "$1" "''${2:-"origin"}/$1"; }; f'';
      d = ''!f() { git diff "''${@:-"HEAD"}" 2>/dev/null || git diff; }; f'';

      fix = convCommit "fix";
      feat = convCommit "feat";
      feet = convCommit "feat";
      chore = convCommit "chore";
    };

    user = {
      email = "contact@nanoyaki.space";
      name = "nanoyaki";
    };
  };
in

{
  flake.homeModules.git = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };

    programs.git.settings = common;
    programs.git.signing = {
      key = "~/.ssh/id_hasu.pub";
      format = "ssh";
      signByDefault = true;
    };
  };

  flake.nixosModules.git =
    { lib, pkgs, ... }:

    {
      programs.git.config = lib.recursiveUpdate common {
        core.pager = lib.getExe pkgs.delta;
        interactive.diffFilter = "${lib.getExe pkgs.delta} --color-only";
        delta = {
          navigate = true;
          line-numbers = true;
          side-by-side = true;
        };

        user.signingKey = "~/.ssh/id_hasu.pub";
        gpg.format = "ssh";

        commit.gpgSign = true;
        tag.gpgSign = true;
        push.gpgSign = "if-asked";
      };
    };
}
