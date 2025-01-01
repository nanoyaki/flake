{
  pkgs,
  ...
}:

{
  programs.git.enable = true;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "update" ''
      find ~ -name "*home-bac" | xargs rm
      pushd $FLAKE_DIR
      git pull
      sudo nixos-rebuild switch --flake $FLAKE_DIR
      popd
    '')
  ];

  system.stateVersion = "25.05";
  hm.home.stateVersion = "25.05";
}
