{ inputs, ... }:

{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    { config, pkgs, ... }:
    let
      inherit (pkgs) callPackage;
    in
    {
      overlayAttrs = {
        inherit (config.packages)
          lighthouse
          lavalink
          startvrc
          writeSystemdToggle
          meow
          ;
      };

      packages = {
        lighthouse = callPackage ./lighthouse { };
        lavalink = callPackage ./lavalink { jdk = pkgs.zulu17; };
        startvrc = callPackage ./startvrc { };
        writeSystemdToggle = callPackage ./writeSystemdToggle { };

        meow = pkgs.meow.overrideAttrs {
          patches = [ ./patches/ominous-cats.patch ];
        };
      };
    };
}
