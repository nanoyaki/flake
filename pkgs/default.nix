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
          vrcx
          meow
          ;
      };

      packages = {
        lighthouse = pkgs.callPackage ./lighthouse { };
        lavalink = pkgs.callPackage ./lavalink { };
        startvrc = pkgs.callPackage ./startvrc { };
        alcom = pkgs.callPackage ./alcom { };
        writeSystemdToggle = pkgs.callPackage ./writeSystemdToggle { };
        vrcx = pkgs.callPackage ./vrcx { };
        meow = pkgs.meow.overrideAttrs {
          patches = [ ./patches/ominous-cats.patch ];
        };
      };
    };
}
