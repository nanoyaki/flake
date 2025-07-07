{ self, ... }:

{
  imports = [
    self.nixosModules.lab-config
    ./media.nix
    ./domains.nix
    ./samba.nix
    ./calendar.nix
    ./bind.nix
    ./restic.nix
    ./uptime-kuma.nix
  ];
}
