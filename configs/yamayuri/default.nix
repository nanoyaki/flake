{ lib', ... }:

{
  flake.nixosConfigurations.yamayuri = lib'.mkServer {
    hostname = "yamayuri";
    platform = "aarch64-linux";

    users = {
      admin = {
        mainUser = true;
        isSuperuser = true;
        home.stateVersion = "25.11";
      };
      root.home.stateVersion = "25.11";
    };

    config = {
      imports = [
        ./hardware
        ./networking

        ./configuration.nix
      ];

      system.stateVersion = "25.11";
    };
  };
}
