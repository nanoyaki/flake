{ lib', ... }:

{
  flake.nixosConfigurations.yuri = lib'.mkServer {
    hostname = "yuri";
    users.nas = {
      mainUser = true;
      isSuperuser = true;
      home.stateVersion = "25.05";
    };
    config = {
      imports = [
        ./hardware

        ./configuration.nix
        ./ssh.nix
        ./servers
        ./deployment.nix
      ];

      system.stateVersion = "25.05";
    };
  };
}
