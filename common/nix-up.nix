{ pkgs, ... }:
pkgs.writeShellScriptBin "nix-up" ''
  pushd $FLAKE_DIR

  nix flake update

  find .. -type f -name '*.home-bac' | xargs rm

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  popd
''
