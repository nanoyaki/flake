{ lib, pkgs, ... }:

let
  name = "nanoyaki";
  email = "hanakretzer@nanoyaki.space";
  signingkey = "31A8CE0D2E7D30C3";
in

{
  hm.programs.git.settings = {
    user = { inherit name email; };

    aliases.co = "checkout";

    signing = {
      key = signingkey;

      signer = lib.getExe pkgs.gnupg;
      signByDefault = true;
    };
  };

  hm.programs.gpg.settings.default-key = signingkey;

  programs.git.config = {
    user = {
      inherit name email signingkey;
    };

    commit.gpgsign = true;
  };
}
