{ pkgs, username, ... }:
pkgs.writeShellScriptBin "nix-up" ''
  pushd $FLAKE_DIR

  nix flake update

  sudo nixos-rebuild switch --flake $FLAKE_DIR

  find /home/${username} -type f -name '*.home-bac' | xargs rm

  popd
''
