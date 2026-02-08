{
  flake.homeModules.hana-ssh =
    { config, ... }:

    let
      identityFile = config.sops.secrets."private_keys/id_nadesiko".path;
    in

    {
      programs.ssh.enable = true;
      programs.ssh.enableDefaultConfig = false;
      programs.ssh.matchBlocks = {
        "*" = {
          inherit identityFile;
          addKeysToAgent = "yes";
          compression = false;
          controlMaster = "auto";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "1h";
        };

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
          forwardAgent = true;
        };
      };
    };
}
