{
  pkgs,
  ...
}:

let
  exec = pkgs.vscodium.meta.mainProgram;
in

{
  environment.systemPackages = [ pkgs.vscodium ];

  environment.variables = {
    EDITOR = exec;
    GIT_EDITOR = "${exec} --wait";
    SOPS_EDITOR = "${exec} --wait";
  };
}
