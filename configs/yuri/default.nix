{
  lib',
  inputs,
  self,
  ...
}:

{
  flake.nixosConfigurations.yuri = lib'.systems.mkServer {
    inherit inputs;
    hostname = "yuri";
    stateVersion = "25.12";
    users = {
      nas = {
        isMainUser = true;
        isSuperuser = true;
        hashedPasswordSopsKey = "users/nas";
        home.stateVersion = "25.05";
      };
      root = {
        hashedPasswordSopsKey = "users/root";
        home.stateVersion = "25.11";
      };
    };
    config = {
      imports = [
        ./hardware

        self.nixosModules.all
        ./configuration.nix
        ./ssh.nix
        ./servers
        ./deployment.nix
      ];

      nanoSystem.sops.defaultSopsFile = ./secrets/host.yaml;
      nanoSystem.localization = {
        language = "en_US";
        locale = "en_US.UTF-8";
      };

      system.stateVersion = "25.05";
    };
  };
}
