{
  imports = [
    ./immich.nix
    ./domains.nix
    ./samba.nix
    # ./calendar.nix
    ./dnsmasq.nix
    ./restic-server.nix
    ./uptime-kuma.nix
    ./caddy.nix
    ./home-assistant.nix
    ./wireguard.nix
  ];
}
