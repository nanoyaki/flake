{
  imports = [
    ./caddy.nix
    ./homepage.nix
    ./homepage-image.nix
    ./ssh.nix
    ./suwayomi.nix
    ./forgejo.nix
    ./minecraft
    ./woodpecker.nix
    ./dynamicdns.nix
    ./syncthing.nix
    ./jellyfin.nix
    ./steam.nix
    ./immich.nix
    ./nix-serve.nix
    ./vaultwarden.nix
    ./arr-stack.nix
    ./uptime-kuma.nix
    ./sabnzbd.nix
  ];

  services.arr-stack.enabled = [
    "bazarr"
    "jellyseerr"
    "prowlarr"
    "radarr"
    "sonarr"
  ];
}
