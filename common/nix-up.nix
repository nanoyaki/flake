{pkgs, ...}:
pkgs.writeShellScriptBin "nix-up" ''
  # aliases for nixpkgs
  alias git="${pkgs.git}/bin/git"

  # change dir to flake dir
  pushd $FLAKE_DIR

  # set vars
  CURRENT_BRANCH="$(git branch --show-current)"
  LAST_COMMIT="$(git rev-parse $CURRENT_BRANCH)"

  # In case of the same commit name
  UNIQUE_VERSION="$(echo "$(git diff)$(date)" | md5sum | cut -c1-6)"

  # check for changes from remote repo
  git fetch origin $CURRENT_BRANCH

  if !(git branch --contains $(git rev-parse origin/$CURRENT_BRANCH)); then
    echo "Warning: Local branch is behind origin. Consider pulling changes before rebuilding."
    popd
    exit 1
  fi

  nix flake update

  git add flake.lock

  # Rebuild and exit on failure
  sudo nixos-rebuild switch --flake $FLAKE_DIR > $HOME/nixos-switch.log || (cat $HOME/nixos-switch.log | grep --color error && exit 1)

  # Commit with the hostname and generation
  git commit -m "$(hostname) $(nixos-rebuild list-generations | grep current | cut -d" " -f1) $UNIQUE_VERSION"
  git push -u origin $CURRENT_BRANCH

  # go back to previous dir
  popd

  echo "OK!"
''
