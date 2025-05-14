{ config, ... }:

let
  identityFile = config.hm.sec."private_keys/id_nadesiko".path;
in

{
  hm.programs.ssh.matchBlocks = {
    yuri = {
      user = "nas";
      hostname = "10.0.0.3";
      inherit identityFile;
    };

    at = {
      user = "thelessone";
      hostname = "theless.one";
      inherit identityFile;
      serverAliveInterval = 60;
      serverAliveCountMax = 180;
    };
  };
}
