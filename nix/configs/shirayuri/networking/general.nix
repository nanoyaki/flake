{
  flake.nixosModules.shirayuri-networking.networking = {
    hostId = "57ced6bb";
    hostName = "shirayuri";

    useDHCP = false;
    networkmanager.enable = true;
  };
}
