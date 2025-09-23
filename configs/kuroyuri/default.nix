{ lib', ... }:

{
  flake.nixosConfigurations.kuroyuri = lib'.mkPortable {
    hostname = "kuroyuri";
    users = {
      hana = {
        mainUser = true;
        isSuperuser = true;
        home.stateVersion = "24.11";
      };
      root.home.stateVersion = "25.11";
    };
    config = {
      imports = [
        ./hardware

        ./configuration.nix
        ./git.nix
        ../shirayuri/librewolf.nix
      ];

      system.stateVersion = "24.05";
    };
  };
}
