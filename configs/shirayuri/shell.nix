{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
    wl-clipboard
  ];
}
