{ pkgs, ... }:

{
  sec."deployment/private" = { };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vesktop
    vscodium
  ];

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
