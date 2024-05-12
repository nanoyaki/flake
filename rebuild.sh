#!/usr/bin/env zsh
# change dir to flake dir
pushd $FLAKE_DIR

# check for changes from remote repo
git fetch origin main
git branch --contains $(git rev-parse origin/main) &> /dev/null

if [ $? -ne 0 ]; then
  # Notify all OK!
  notify-send "NixOS Rebuilt failed!" --icon=software-update-available --app-name="Flake" --urgency="critical"
  echo "Warning: Local main branch is behind origin/main. Consider pulling changes before rebuilding."
  popd
  exit 1
fi

# Show changes compared to the last commit
git diff -U0 $(git rev-parse main) -- '*.nix'

# Rebuild and exit on failure
sudo nixos-rebuild switch --flake $FLAKE_DIR &>$HOME/nixos-switch.log || (cat $HOME/nixos-switch.log | grep --color error && exit 1)

# Commit with the hostname and generation
git commit -m "$(hostname) $(nixos-rebuild list-generations | grep current | cut -d" " -f1)"

# push changes to the remote repo
git push -u origin main

# go back to previous dir
popd

# Notify all OK!
notify-send -e "NixOS Rebuilt OK" --icon=software-update-available --app-name="Flake"