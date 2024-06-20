{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Programming
    mongodb-compass
    jetbrains.rider
    jetbrains.rust-rover

    # Games
    protonup
    bottles
    parsec-bin
    cartridges
    lutris-unwrapped
    osu-lazer-bin
    modrinth-app
  ];
}
