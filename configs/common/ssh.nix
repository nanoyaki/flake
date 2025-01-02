{ config, ... }:

let
  identityFile = "${config.hm.home.homeDirectory}/.ssh/${config.networking.hostName}-primary";
in

{
  hm.programs.ssh = {
    enable = true;

    matchBlocks = {
      server = {
        user = "thelessone";
        hostname = "theless.one";
        inherit identityFile;
      };
      git = {
        user = "git";
        host = "github.com codeberg.org gitlab.com";
        inherit identityFile;
      };
    };

    extraConfig = ''
      IdentityFile ${identityFile}
    '';
  };
}
