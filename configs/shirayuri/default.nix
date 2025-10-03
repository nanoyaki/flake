{
  lib',
  inputs,
  self,
  ...
}:

{
  flake.nixosConfigurations.shirayuri = lib'.systems.mkDesktop {
    inherit inputs;
    hostname = "shirayuri";
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
      { lib, config, ... }:

      {
        imports = [
          ./hardware

          self.nixosModules.all
          self.nixosModules.vr
          ./configuration.nix
          ./xdg.nix
          ./gaming
          ./git.nix
          ./ssh.nix
          ./backup.nix
          ./librewolf.nix
          ./qemu.nix
        ];

        nanoSystem = {
          localization.language = [
            "en_GB"
            "de_DE"
            "ja_JP"
          ];
          keyboard.layout = "de";
          fcitx5.enable = true;
          audio.latency = lib.mkDefault 256;
          ssh.defaultId = "${config.hm.home.homeDirectory}/.ssh/shirayuri-primary";
          sops.defaultSopsFile = ./secrets/host.yaml;
        };

        system.stateVersion = "24.11";
      };
  };
}
