{
  imports = [
    ./arr-stack.nix
    ./jellyfin.nix
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
