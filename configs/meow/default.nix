{
  inputs,
  self,
  lib',
  ...
}:

let
  inherit (inputs) home-manager nixpkgs-unstable;

  username = "hana";
  arch = "x86_64-linux";
in

{
  flake.homeConfigurations."hana@meow" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs-unstable.legacyPackages.${arch};
    extraSpecialArgs = {
      inherit
        inputs
        username
        lib'
        self
        ;

      packages = self.packages.${arch};
    };
    modules = [
      self.homeManagerModules.symlinks
      ./nix.nix
      ./sops.nix
      ./configuration.nix
      ./steam.nix
    ];
  };
}
