{
  configurations.nixos.shirayuri = {
    hardware.facter.reportPath = ./facter.json;
    system.stateVersion = "24.11";
  };
}
