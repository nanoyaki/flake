{ config, ... }:

let
  identityFile = "${config.hm.home.homeDirectory}/.ssh/${config.networking.hostName}-primary";
in

{
  hm.programs.ssh = {
    enable = true;

    matchBlocks.git = {
      user = "git";
      host = "github.com codeberg.org gitlab.com git.theless.one";
      inherit identityFile;
    };

    extraConfig = ''
      IdentityFile ${identityFile}
    '';
  };
}
