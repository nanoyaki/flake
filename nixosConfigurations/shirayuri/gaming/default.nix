{
  pkgs,
  ...
}:

{
  imports = [
    ./steam.nix
    ./minecraft.nix
    ./anime-games.nix
  ];

  environment.systemPackages = with pkgs; [
    bottles
    cartridges
    lutris

    mangohud

    osu-lazer-bin
  ];

  programs.gamemode.enable = true;
}
