{ pkgs, ... }:

{
  hm.home.packages = with pkgs; [
    vesktop

    obsidian

    bitwarden-desktop

    anki
  ];
}
