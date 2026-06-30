{
  flake.nixosModules.kuroyuri-networking.networking = {
    hostId = "4433d464";
    hostName = "kuroyuri";

    useDHCP = false;
    networkmanager.enable = true;
  };
}
