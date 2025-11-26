let
  name = "nanoyaki";
  email = "hanakretzer@nanoyaki.space";
  signingkey = "31A8CE0D2E7D30C3";
in

{
  hm.programs.git.settings = {
    user = { inherit name email; };

    aliases.co = "checkout";
  };

  programs.git.config.user = {
    inherit name email signingkey;
  };
}
