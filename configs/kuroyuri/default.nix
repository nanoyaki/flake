{ deps, ... }:

{
  flake.nixosConfigurations = deps.mkSystem {
    hostname = "kuroyuri";
    username = "hana";
    modules = [
      ../common

      ./hardware

      ./configuration.nix
      ./gaming.nix
      ./git.nix
    ];
  };
}
