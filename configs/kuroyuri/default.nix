{
  lib',
  inputs,
  self,
  ...
}:

{
  flake.nixosConfigurations.kuroyuri = lib'.systems.mkPortable {
    inherit inputs;
    hostname = "kuroyuri";
    users = {
      hana = {
        isMainUser = true;
        isSuperuser = true;
        hashedPasswordSopsKey = "users/hana";
        home.stateVersion = "24.11";
      };
      root = {
        hashedPasswordSopsKey = "users/root";
        home.stateVersion = "25.11";
      };
    };
    config =
      { config, ... }:

      {
        imports = [
          ./hardware

          self.nixosModules.all
          ./configuration.nix
          ../shirayuri/librewolf.nix
        ];

        nanoSystem = {
          localization.language = [
            "en_GB"
            "de_DE"
            "ja_JP"
          ];
          fcitx5.enable = true;

          ssh.defaultId = "${config.hm.home.homeDirectory}/.ssh/id_nadesiko";
          sops.defaultSopsFile = ./secrets/host.yaml;
        };

        system.stateVersion = "24.05";
      };
  };
}
