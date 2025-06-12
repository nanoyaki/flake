{
  lib',
  pkgs,
  ...
}:

{
  imports = [
    ./anime-games.nix
    ./rpgmaker.nix
    ./cs.nix
  ];

  environment.systemPackages = lib'.mapLazyApps (
    with pkgs;
    [
      { pkg = dolphin-emu; }
      { pkg = lutris; }
      { pkg = mangohud; }
      { pkg = osu-lazer-bin; }
    ]
  );

  programs.gamemode.enable = true;
}
