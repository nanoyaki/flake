{ nLib, self, ... }:

{
  flake.nixosConfigurations = nLib.mkSystem {
    hostname = "shirayuri";
    modules = [
      ../common

      self.nixosModules.x3d-undervolt
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
