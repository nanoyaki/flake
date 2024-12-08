{
  flake.nixosModules = {
    suwayomi = import ./suwayomi;
    lavalink = import ./lavalink;
  };
}
