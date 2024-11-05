{ ... }:

{
  imports = [
    ./nix.nix
    ./boot.nix
    ./home.nix
    ./user.nix
    ./networking.nix
    ./locale.nix
    ./sops
    ./input.nix
    ./fonts.nix
    ./terminal.nix
    ./audio.nix
    ./plasma.nix
    ./files.nix
    ./programming.nix
    ./chrome.nix
    ./mpv.nix
    ./theme.nix
  ];
}
