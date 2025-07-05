{ self, ... }:

{
  imports = [
    self.nixosModules.lab-config
    ./media.nix
    ./ddclient.nix
    ./samba.nix
    ./calendar.nix
    ./bind.nix
    ./restic.nix
    ./uptime-kuma.nix
  ];
}
