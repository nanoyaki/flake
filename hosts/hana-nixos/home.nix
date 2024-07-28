{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Programming
    mongodb-compass
    jetbrains.phpstorm

    # Games
    bottles
    parsec-bin
    cartridges
    lutris-unwrapped
    osu-lazer-bin

    # Image manipulation
    imagemagick
    gimp

    # Files
    file-roller
    unrar
    unzip
    p7zip

    # Misc
    kdePackages.kalarm
  ];
}
