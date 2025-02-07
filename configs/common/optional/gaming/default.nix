{
  imports = [
    ./minecraft.nix
    ./steam.nix
  ];

  services.flatpak.enable = true;
}
