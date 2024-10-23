{
  pkgs,
  config,
  ...
}:

pkgs.writeShellScriptBin "rebuild" ''
  finish () {
    exit 0
  }
  trap finish SIGINT

  pushd $FLAKE_DIR

  LAST_GEN="$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')"

  sudo nixos-rebuild switch --flake $FLAKE_DIR#${config.networking.hostName}
  if [[ $LAST_GEN == "$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')" ]]; then
    ${pkgs.libnotify}/bin/notify-send "NixOS Rebuild" "An error occurred during rebuild of the system" -a "NixOS" -i nix-snowflake -u critical
    exit 1
  fi

  FIND_RESULT="$(find ${config.hm.home.homeDirectory} -type f -name '*.home-bac')"
  [[ $FIND_RESULT ]] && rm $FIND_RESULT

  ${pkgs.libnotify}/bin/notify-send "NixOS Update" "The system finished rebuilding" -a "NixOS" -i nix-snowflake

  popd
''
