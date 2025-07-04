{
  inputs,
  self,
  lib',
  ...
}:

let
  inherit (inputs) home-manager nixpkgs nanopkgs;

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

        packages = nanopkgs.packages.${arch};
      };
      modules = [
        self.homeManagerModules.symlinks
        ./nix.nix
        ./sops.nix
        ./home.nix
        ./shell.nix
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
        packages = nanopkgs.packages.${arch};
      };
      modules = [
        ./nix.nix
        ./home.nix
        ./shell.nix
        ./root/environment.nix
        ./root/dbus.nix
        ./root/systemd.nix
        ./root.nix
      ];
    };
  };
}
