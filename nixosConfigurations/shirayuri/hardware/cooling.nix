{ pkgs, ... }:
{
  boot.extraModulePackages = with pkgs; [ linuxKernel.packages.linux_zen.it87 ];
  boot.kernelModules = [ "it87" ];

  environment.systemPackages = with pkgs; [ linuxKernel.packages.linux_zen.it87 ];

  programs.coolercontrol.enable = true;
}
