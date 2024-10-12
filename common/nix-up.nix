{ pkgs, username, ... }:
pkgs.writeShellScriptBin "nix-up" ''
  pushd $FLAKE_DIR

  nix flake update

  find /home/${username} -type f -name '*.home-bac' | xargs rm

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  popd
''
