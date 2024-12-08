{ lib, config, ... }:

let
  inherit (lib) mkMerge;

  identityFile = "${config.hm.home.homeDirectory}/.ssh/${config.networking.hostName}-primary";

  mkGitBlocks =
    domains:
    mkMerge (
      builtins.map (domain: {
        ${domain} = {
          user = "git";
          hostname = domain;
          inherit identityFile;
        };
      }) domains
    );
in

{
  hm.programs.ssh = {
    enable = true;

    matchBlocks =
      {
        server = {
          user = "thelessone";
          hostname = "theless.one";
          inherit identityFile;
        };
      }
      // (mkGitBlocks [
        "github.com"
        "codeberg.org"
        "gitlab.com"
      ]);

    extraConfig = ''
      IdentityFile ${identityFile}
    '';
  };
}
