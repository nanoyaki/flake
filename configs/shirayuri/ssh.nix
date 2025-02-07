{ config, ... }:

{
  hm.programs.ssh.matchBlocks.nas = {
    user = "nas";
    host = "192.168.8.101";
    identityFile = config.hm.sec."private_keys/id_ume".path;
  };
}
