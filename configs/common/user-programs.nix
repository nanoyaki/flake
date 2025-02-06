{ pkgs, ... }:

{
  hm.home.packages = with pkgs; [
    (vesktop.override { withMiddleClickScroll = true; })

    obsidian

    bitwarden-desktop

    anki
  ];
}
