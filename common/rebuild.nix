{ pkgs, config, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  finish () {
    exit 0
  }
  trap finish SIGINT

  pushd $HOME

  alias notify-send="${pkgs.libnotify}/bin/notify-send"

  rm $HOME/nixos-rebuild.log
  sudo nixos-rebuild switch --flake $FLAKE_DIR#${config.networking.hostName} 2>&1 | tee nixos-rebuild.log
  if grep -q "error" nixos-rebuild.log; then
    cat $HOME/nixos-rebuild.log
    notify-send "NixOS Rebuild" "An error occurred during rebuild of the system. See $HOME/nixos-rebuild.log for more information." -a "NixOS" --icon=nix-snowflake -u=critical
    exit 1
  fi

  notify-send "NixOS Rebuild" "The system finished rebuilding" -a "NixOS" --icon=nix-snowflake

  popd
''
