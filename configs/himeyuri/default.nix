{ lib', ... }:

{
  flake.nixosConfigurations.himeyuri = lib'.mkDesktop {
    hostname = "himeyuri";
    users = {
      hana = {
        mainUser = true;
        isSuperuser = true;
        home.stateVersion = "25.11";
      };
      root.home.stateVersion = "25.11";
    };
    config = {
      imports = [
        ./hardware

        ./configuration.nix
        ../shirayuri/librewolf.nix
      ];

      system.stateVersion = "25.11";
    };
  };
}
