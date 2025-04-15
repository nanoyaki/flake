{
  lib,
  pkgs,
  ...
}:

let
  exec = lib.getExe pkgs.vscodium;
in

{
  environment.systemPackages = [
    pkgs.vscodium
  ];

  environment.variables = {
    EDITOR = exec;
    GIT_EDITOR = "${exec} --wait";
    SOPS_EDITOR = "${exec} --wait";
  };
}
