{ lib, config, ... }:

let
  inherit (lib) singleton;
  identityFile = config.hm.sops.secrets."private_keys/id_nadesiko".path;
in

{
  hms = singleton {
    programs.ssh.matchBlocks = {
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
  };
}
