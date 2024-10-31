{ nLib, ... }:

{
  flake.nixosConfigurations = nLib.mkSystem {
    hostname = "shirayuri";
    modules = [
      ../common

      ./hardware

      ./boot.nix
      ./symlinks.nix
      ./gaming.nix
      ./emulation.nix
      ./vr
      ./configuration.nix
    ];
  };
}
