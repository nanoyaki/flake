{
  pkgs,
  config,
  username,
  ...
}:
pkgs.writeShellScriptBin "nix-up" ''
  finish () {
    exit 0
  }
  trap finish SIGINT

  pushd $HOME

  nix flake update

  rm $HOME/nixos-rebuild.log
  sudo nixos-rebuild switch --flake $FLAKE_DIR#${config.networking.hostName} 2>&1 | tee nixos-rebuild.log
  if grep -q "error" nixos-rebuild.log; then
    cat $HOME/nixos-rebuild.log
    ${pkgs.libnotify}/bin/notify-send "NixOS Rebuild" "An error occurred during rebuild of the system" -a "NixOS" --icon=nix-snowflake -u=critical
    exit 1
  fi

  FIND_RESULT="$(find /home/${username} -type f -name '*.home-bac')"
  [[ $FIND_RESULT ]] && rm $FIND_RESULT

  ${pkgs.libnotify}/bin/notify-send "NixOS Update" "The system finished updating and rebuilding" -a "NixOS" --icon=nix-snowflake

  popd
''
