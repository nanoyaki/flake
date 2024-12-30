{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.git.enable = true;

  sec."nixos/users/thelessone-lesstop".neededForUsers = true;
  users.users.thelessone.hashedPasswordFile =
    lib.mkForce
      config.sec."nixos/users/thelessone-lesstop".path;

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
}
