{
  imports = [
    ./immich.nix
    ./domains.nix
    ./samba.nix
    # ./calendar.nix
    ./coredns.nix
    ./restic-server.nix
    ./uptime-kuma.nix
    ./caddy.nix
    ./home-assistant.nix
    ./wireguard.nix
  ];
}
