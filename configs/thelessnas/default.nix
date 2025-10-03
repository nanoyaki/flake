{
  lib',
  inputs,
  self,
  ...
}:

{
  flake.nixosConfigurations.thelessnas = lib'.systems.mkServer {
    inherit inputs;
    hostname = "thelessnas";
    users = {
      admin = {
        isMainUser = true;
        isSuperuser = true;
        hashedPasswordSopsKey = "users/admin";
        home.stateVersion = "25.11";
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
        ./openssh.nix
        ./deployment.nix
        ./zfs.nix
        ./restic.nix
      ];

      nanoSystem.sops.defaultSopsFile = ./secrets/host.yaml;
      nanoSystem.localization = {
        timezone = "Europe/Vienna";
        language = [
          "de_AT"
          "en_GB"
        ];
        locale = "de_AT.UTF-8";
      };

      system.stateVersion = "24.11";
    };
  };
}
