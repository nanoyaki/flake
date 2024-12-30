{ lib, config, ... }:

{
  programs.git.enable = true;

  sec."nixos/users/thelessone-lesstop".neededForUsers = true;
  users.users.thelessone.hashedPasswordFile =
    lib.mkForce
      config.sec."nixos/users/thelessone-lesstop".path;

  system.stateVersion = "25.05";
}
