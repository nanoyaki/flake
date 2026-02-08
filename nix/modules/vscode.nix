{
  flake.nixosModules.vscode =
    { lib, pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        vscodium
        nixd
      ];

      environment.sessionVariables = {
        EDITOR = lib.getExe pkgs.vscodium;
        GIT_EDITOR = "${lib.getExe pkgs.vscodium} --wait";
        SOPS_EDITOR = "${lib.getExe pkgs.vscodium} --wait";
      };
    };
}
