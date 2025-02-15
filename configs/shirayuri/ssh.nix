{ config, ... }:

let
  identityFile = config.hm.sec."private_keys/id_ume".path;
in

{
  hm.programs.ssh.matchBlocks = {
    nas = {
      user = "nas";
      host = "nas";
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
