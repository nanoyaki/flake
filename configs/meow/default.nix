{
  inputs,
  self,
  lib',
  ...
}:

let
  inherit (inputs) home-manager nixpkgs;

  username = "hana";
  arch = "x86_64-linux";
in

{
  flake = {
    homeConfigurations."hana@meow" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${arch};
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
        ./home.nix
        ./configuration.nix
        ./steam.nix
        ./vr.nix
        ./vrchat.nix
        ./cpu.nix
      ];
    };

    homeConfigurations."root@meow" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${arch};
      extraSpecialArgs = {
        inherit
          inputs
          lib'
          self
          ;

        username = "root";
        packages = self.packages.${arch};
      };
      modules = [
        ./nix.nix
        ./home.nix
        ./shell.nix
        ./root.nix
        ./root/systemd.nix
      ];
    };
  };
}
