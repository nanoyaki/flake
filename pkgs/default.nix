{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        lighthouse = pkgs.callPackage ./lighthouse { };
        lavalink = pkgs.callPackage ./lavalink { };
      };
    };
}
