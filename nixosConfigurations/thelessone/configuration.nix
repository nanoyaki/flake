{ pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = [ pkgs.vesktop ];

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
