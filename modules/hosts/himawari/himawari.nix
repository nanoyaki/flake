{
  configurations.nixos.himawari = {
    hardware.facter.reportPath = ./facter.json;
    system.stateVersion = "26.11";
  };
}
