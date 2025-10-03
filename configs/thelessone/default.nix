{
  lib',
  inputs,
  self,
  ...
}:

{
  flake.nixosConfigurations.thelessone = lib'.systems.mkDesktop {
    inherit inputs;
    hostname = "thelessone";
    users = {
      thelessone = {
        isMainUser = true;
        isSuperuser = true;
        hashedPasswordSopsKey = "users/thelessone";
        home.stateVersion = "24.11";
      };
      root = {
        hashedPasswordSopsKey = "users/root";
        home.stateVersion = "25.11";
      };
    };
    config = {
      imports = [
        ./hardware
        ./networking

        self.nixosModules.all
        ./configuration.nix
        ./git.nix
        ./servers
        ./terminal.nix
        # ./beets.nix
      ];

      nanoSystem = {
        localization = {
          timezone = "Europe/Vienna";
          language = "de_AT";
          locale = "de_AT.UTF-8";
        };
        sops.defaultSopsFile = ./secrets/host.yaml;
      };

      networking.hostId = "f617b7b6";
      system.stateVersion = "24.11";
    };
  };
}
