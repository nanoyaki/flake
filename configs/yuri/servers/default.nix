{
  imports = [
    ./samba.nix
    ./calendar.nix
    ./files.nix
    ./bind.nix
    ./caddy.nix
    ./homepage-image.nix
    ./homepage.nix
    ./home-assistant.nix
    ./paperless.nix
    ./immich.nix
    ./vaultwarden.nix
    ./jellyfin.nix
    ./arr-stack.nix
  ];

  services.arr-stack.enabled = [ ];
  services.homepage-easify.categories."Smart Home".before = "Medien";
}
