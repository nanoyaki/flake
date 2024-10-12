{ pkgs, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  pushd $FLAKE_DIR

  find .. -type f -name '*.home-bac' | xargs rm

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  popd
''
