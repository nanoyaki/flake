{
  flake.nixosModules.vscode =
    { lib, pkgs, ... }:

    {
      environment.systemPackages = [ pkgs.vscodium ];

      environment.sessionVariables = {
        EDITOR = lib.getExe pkgs.vscodium;
        GIT_EDITOR = "${lib.getExe pkgs.vscodium} --wait";
        SOPS_EDITOR = "${lib.getExe pkgs.vscodium} --wait";
      };
    };
}
