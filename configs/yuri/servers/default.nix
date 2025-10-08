{
  imports = [
    ./immich.nix
    ./domains.nix
    ./samba.nix
    # ./calendar.nix
    ./bind.nix
    ./restic-server.nix
    ./uptime-kuma.nix
    ./caddy.nix
    ./home-assistant.nix
  ];
}
