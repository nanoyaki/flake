{ inputs, ... }:

{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    { config, pkgs, ... }:
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
        lighthouse = pkgs.callPackage ./lighthouse { };
        lavalink = pkgs.callPackage ./lavalink { };
        startvrc = pkgs.callPackage ./startvrc { };
        writeSystemdToggle = pkgs.callPackage ./writeSystemdToggle { };
        meow = pkgs.meow.overrideAttrs {
          patches = [ ./patches/ominous-cats.patch ];
        };
      };
    };
}
