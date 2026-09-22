{
  configurations.nixos.kanokoyuri = {
    hardware.facter.reportPath = ./facter.json;
    system.stateVersion = "25.11";
  };
}
