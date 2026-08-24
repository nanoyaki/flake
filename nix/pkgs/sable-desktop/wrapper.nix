{ withSystem, ... }:

{
  perSystem =
    { pkgs, ... }:

    {
      packages.sable-desktop = pkgs.callPackage ./_package.nix { };
    };

  flake.overlays.sable-desktop =
    _: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: { inherit (config.packages) sable-desktop; }
    );
}
