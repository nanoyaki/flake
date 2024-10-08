{ pkgs, ... }:
pkgs.writeShellScriptBin "nix-up" ''
  pushd $FLAKE_DIR

  nix flake update

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  popd
''
