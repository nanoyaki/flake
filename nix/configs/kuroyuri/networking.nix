{
  flake.nixosModules.kuroyuri-networking = {
    services.tailscale.enable = true;

    networking = {
      hostId = "4433d464";
      hostName = "kuroyuri";
      networkmanager.enable = true;
      useDHCP = false;
    };
  };
}
