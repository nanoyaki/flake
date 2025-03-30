{ config, ... }:

let
  identityFile = config.hm.sec."private_keys/id_nadesiko".path;
in

{
  hm.programs.ssh.matchBlocks = {
    yuri = {
      user = "nas";
      hostname = "192.168.8.101";
      inherit identityFile;
    };

    at = {
      user = "thelessone";
      hostname = "theless.one";
      inherit identityFile;
    };
  };
}
