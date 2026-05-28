{
  flake.homeModules.hana-ssh =
    { config, ... }:

    let
      IdentityFile = config.sops.secrets."private_keys/id_nadesiko".path;
    in

    {
      programs.ssh.enable = true;
      programs.ssh.enableDefaultConfig = false;
      programs.ssh.settings = {
        "*" = {
          ForwardAgent = true;
          AddKeysToAgent = "yes";
          Compression = false;
          ControlMaster = "auto";
          ControlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
          ControlPersist = "1h";
          inherit IdentityFile;
        };

        kanoko = {
          HostName = "10.0.0.9";
          User = "kanoko";
          inherit IdentityFile;
        };

        thelessone = {
          User = "thelessone";
          HostName = "theless.one";
          ServerAliveInterval = 60;
          ServerAliveCountMax = 180;
          inherit IdentityFile;
        };

        "Host git.theless.one" = {
          User = "git";
          inherit IdentityFile;
        };

        sentinel = {
          User = "root";
          HostName = "85.215.152.236";
          inherit IdentityFile;
        };

        "Host github.com" = {
          HostName = "github.com";
          User = "git";
          inherit IdentityFile;
        };
      };
    };
}
