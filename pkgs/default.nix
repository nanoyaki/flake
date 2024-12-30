{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        lighthouse = pkgs.callPackage ./lighthouse { };
        lavalink = pkgs.callPackage ./lavalink { };
        startvrc = pkgs.callPackage ./startvrc { };
        alcom = pkgs.callPackage ./alcom { };
      };
    };
}
