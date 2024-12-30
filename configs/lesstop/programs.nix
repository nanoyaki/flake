{ pkgs, ... }:

{
  hm.home.packages = with pkgs; [
    vesktop
    bitwarden-desktop
    vscodium
  ];
}
