{ nLib, ... }:

{
  flake.nixosConfigurations = nLib.mkSystem {
    hostname = "shirayuri";
    modules = [
      ../common

      ./hardware

      ./boot.nix
      ./symlinks.nix
      ./gaming
      ./emulation.nix
      ./vr
      ./configuration.nix
    ];
  };
}
