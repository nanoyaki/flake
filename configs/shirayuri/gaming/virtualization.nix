{ pkgs, inputs', ... }:

{
  environment.systemPackages = [
    pkgs.qemu
    inputs'.quickemu.packages.quickemu
  ];
}
