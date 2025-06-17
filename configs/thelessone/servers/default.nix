{ self, lib', ... }:

{
  imports = [
    ./lab.nix
    ./caddy.nix
    ./ssh.nix
    (import ./suwayomi.nix { inherit self lib'; })
    ./forgejo.nix
    ./minecraft
    ./woodpecker.nix
    ./dynamicdns.nix
    ./syncthing.nix
    ./steam.nix
    ./nix-serve.nix
    ./uptime-kuma.nix
    ./dns.nix
    ./headscale.nix
    ./metrics.nix
    ./stash.nix
    ./shoko.nix
    ./homepage.nix
  ];
}
