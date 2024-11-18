{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "kuroyuri";
    modules = [
      ./hardware
      ./boot.nix

      ./configuration.nix
      ./gaming.nix

      ../common
    ];
  };
}
