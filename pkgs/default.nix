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
      overlayAttrs = config.packages;

      packages = {
        lavalink = callPackage ./lavalink { jdk = pkgs.zulu17; };
        startvrc = callPackage ./startvrc { };
        writeSystemdToggle = callPackage ./writeSystemdToggle { };
        pyon = callPackage ./pyon { };
        midnight-theme = callPackage ./midnight-theme { };

        meow = pkgs.meow.overrideAttrs {
          patches = [ ./patches/ominous-cats.patch ];
        };
      };
    };
}
