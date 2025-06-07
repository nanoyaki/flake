{ config, ... }:

{
  boot = {
    kernelModules = [ "it87" ];
    extraModulePackages = [ config.boot.kernelPackages.it87 ];
  };

  programs.coolercontrol.enable = true;
  # For control within the network
  networking.firewall.allowedTCPPorts = [ 11987 ];
}
