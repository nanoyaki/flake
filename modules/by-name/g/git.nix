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
  fingerprint = builtins.readFile (
    pkgs.runCommand "fingerprint" { inherit gpgKey; } ''
      export GNUPGHOME=$(mktemp -d)
      ${lib.getExe pkgs.gnupg} \
        -v \
        --show-keys \
        --with-colons \
        --with-subkey-fingerprint \
        "$gpgKey" \
        | tail -1 \
        | grep -oP '[\dA-Z]+' \
        | tr -d '\n' \
        > $out
    ''
  );
in

{
  hm = {
    programs.git = {
      settings = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        fetch.all = true;
        pull.autoStash = true;
        pull.rebase = true;
        rebase.autoStash = true;

        core.pager = lib.getExe pkgs.bat;
        pretty.chlog = "format:* %H %s";

        alias = {
          rv = "remote -v";
          rb = "rebase";
          rbi = "rebase -i";
          co = "checkout -b";
          cor = ''!f() { git checkout -B "$1" "''${2:-"origin"}/$1"; }; f'';
          diff = ''!f() { git diff "$*" | bat -l diff; }; f'';
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

  programs.git.config = {
    init.defaultBranch = "main";
    push.autoSetupRemote = true;
    fetch.all = true;
    pull.autoStash = true;
    pull.rebase = true;
    rebase.autoStash = true;

    core.pager = lib.getExe pkgs.bat;
    pretty.chlog = "format:* %H %s";

    alias = {
      rv = "remote -v";
      rb = "rebase";
      rbi = "rebase -i";
      co = "checkout -b";
      cor = ''!f() { git checkout -B "$1" "''${2:-"origin"}/$1"; }; f'';
      diff = ''!f() { git diff "$*" | bat -l diff; }; f'';
    };

    user = {
      email = "hanakretzer@nanoyaki.space";
      name = "nanoyaki";
      signingKey = fingerprint;
    };
    gpg.format = "openpgp";
    gpg.openpgp.program = lib.getExe pkgs.gnupg;
    commit.gpgSign = true;
    tag.gpgSign = true;
  };
}
