{ nLib, ... }:

{
  flake.nixosConfigurations = nLib.mkSystem {
    hostname = "kuroyuri";
    modules = [
      ./hardware
      ./boot.nix

      ../common
    ];
  };
}
