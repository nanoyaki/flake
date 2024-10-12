{ pkgs, username, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  pushd $FLAKE_DIR

  find /home/${username} -type f -name '*.home-bac' | xargs rm

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  popd
''
