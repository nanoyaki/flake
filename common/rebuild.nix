{pkgs, ...}:
pkgs.writeShellScriptBin "rebuild" ''
  # aliases for nixpkgs
  alias git="${pkgs.git}/bin/git"

  # change dir to flake dir
  pushd $FLAKE_DIR

  # set vars
  CURRENT_BRANCH="$(git branch --show-current)"
  LAST_COMMIT="$(git rev-parse $CURRENT_BRANCH)"

  # check for changes from remote repo
  git fetch origin $CURRENT_BRANCH

  if !(git branch --contains $(git rev-parse origin/$CURRENT_BRANCH)); then
    echo "Warning: Local branch is behind origin. Consider pulling changes before rebuilding."
    popd
    exit 1
  fi

  if git diff --quiet $LAST_COMMIT -- '*.nix'; then
    echo "No changes detected, exiting."
    popd
    exit 0
  fi

  git add .

  # Show changes compared to the last commit
  git diff -U0 $LAST_COMMIT -- '*.nix'

  # Rebuild and exit on failure
  sudo nixos-rebuild switch --flake $FLAKE_DIR > $HOME/nixos-switch.log || (cat $HOME/nixos-switch.log | grep --color error && exit 1)

  # Commit with the hostname and generation
  git commit -m "$(hostname) $(nixos-rebuild list-generations | grep current | cut -d" " -f1)"
  git push -u origin $CURRENT_BRANCH

  # go back to previous dir
  popd

  echo "OK!"
''
