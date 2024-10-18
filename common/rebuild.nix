{ pkgs, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  pushd $FLAKE_DIR

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  popd
''
