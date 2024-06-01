{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Games
    protonup
    bottles
    parsec-bin
    cartridges
    lutris-unwrapped
  ];
}
