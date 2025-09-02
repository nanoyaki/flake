{ pkgs, ... }:

{
  imports = [
    ./home-manager.nix
    ./audio.nix
    ./fonts.nix
    ./desktop.nix
    ./networking.nix
    ./vscode.nix
    ./inputs.nix
    ./nix.nix
  ];

  hms = [
    {
      home.packages = with pkgs; [
        (vesktop.override { withMiddleClickScroll = true; })
        bitwarden-desktop
      ];
    }
  ];

  programs.firefox.enable = true;
  environment.systemPackages = [ pkgs.alacritty ];
}
