{
  self,
  lib',
  inputs,
  ...
}:

{
  flake.nixosConfigurations.himeyuri = lib'.systems.mkDesktop {
    inherit inputs;
    hostname = "himeyuri";
    users = {
      hana = {
        isMainUser = true;
        isSuperuser = true;
        hashedPasswordSopsKey = "users/hana";
        home.stateVersion = "25.11";
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
          self.nixosModules.vr
          ./configuration.nix
          ../shirayuri/librewolf.nix
        ];

        nanoSystem = {
          localization = {
            timezone = "Europe/Stockholm";
            language = "en_GB";
            locale = "sv_SE.UTF-8";
          };
          keyboard.layout = "se";
          fcitx5.enable = true;

          audio.latency = 256;
          ssh.defaultId = "${config.hm.home.homeDirectory}/.ssh/id_nadesiko";
          sops.defaultSopsFile = ./secrets/host.yaml;
        };

        system.stateVersion = "25.11";
      };
  };
}
