{
  lib',
  inputs,
  self,
  ...
}:

let
  inherit (inputs) nixos-raspberrypi;
in

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
      imports =
        (with nixos-raspberrypi.nixosModules; [
          nixos-raspberrypi.lib.inject-overlays
          trusted-nix-caches
          nixpkgs-rpi
          # nixos-raspberrypi.lib.inject-overlays-global
        ])
        ++ [
          ./hardware
          ./networking

          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          self.nixosModules.all
          ./configuration.nix
          # ./load-balancing.nix
          ./caddy.nix
          ./dyndns.nix
          ./hass.nix
          ./wireguard.nix
          ./calendar.nix
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
