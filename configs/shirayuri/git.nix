{ lib, pkgs, ... }:

let
  name = "nanoyaki";
  email = "hanakretzer@gmail.com";
  signingkey = "4682C5CB4D9DEA3C";
in

{
  hm.programs.git = {
    userName = name;
    userEmail = email;

    aliases = {
      co = "checkout";
    };

    signing = {
      key = signingkey;

      signer = "${lib.getExe pkgs.gnupg}";
      signByDefault = true;
    };
  };

  programs.git.config = {
    user = {
      inherit name email signingkey;
    };

    commit.gpgsign = true;
  };
}
