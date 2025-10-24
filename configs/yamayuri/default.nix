{
  lib',
  inputs,
  self,
  ...
}:

{
  flake.nixosConfigurations.yamayuri = lib'.systems.mkServer {
    inherit inputs;
    hostname = "yamayuri";
    platform = "aarch64-linux";

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
        ./networking

        self.nixosModules.all
        ./configuration.nix
        # ./load-balancing.nix
        ./caddy.nix
        ./dyndns.nix
        ./hass.nix
        ./wireguard.nix
      ];

      nanoSystem.sops.defaultSopsFile = ./secrets/host.yaml;
      nanoSystem.localization = {
        timezone = "Europe/Berlin";
        language = [
          "en_GB"
          "de_DE"
        ];
        locale = "en_GB.UTF-8";
      };

      system.stateVersion = "25.11";
    };
  };
}
