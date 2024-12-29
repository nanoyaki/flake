{
  pkgs,
  ...
}:

{
  imports = [
    ./steam.nix
    ./minecraft.nix
    ./anime-games.nix
    ./rpgmaker.nix
  ];

  environment.systemPackages = with pkgs; [
    lutris

    mangohud

    osu-lazer-bin
  ];

  programs.gamemode.enable = true;
}
