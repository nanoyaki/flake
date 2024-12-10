{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "kuroyuri";
    username = "hana";
    modules = [
      ./hardware

      ./configuration.nix
      ./gaming.nix
      ./git.nix

      ../common
    ];
  };
}
