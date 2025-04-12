{
  flake.nixosModules = {
    suwayomi = import ./suwayomi;
    dynamicdns = import ./dynamicdns;
  };
}
