{
  pkgs,
  ...
}:

{
  imports = [
    ./anime-games.nix
    ./rpgmaker.nix
    ./cs.nix
  ];

  environment.systemPackages = with pkgs; [
    lutris

    mangohud

    osu-lazer-bin
  ];

  programs.gamemode.enable = true;
}
