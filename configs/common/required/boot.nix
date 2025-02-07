{ pkgs, inputs, ... }:

{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  nix.settings.trusted-substituters = [ "https://lanzaboote.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
  ];

  time.hardwareClockInLocalTime = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader.efi.canTouchEfiVariables = true;
  };
}
