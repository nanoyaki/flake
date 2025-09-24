let
  name = "nanoyaki";
  email = "hanakretzer@nanoyaki.space";
in

{
  hm.programs.git = {
    userName = name;
    userEmail = email;

    aliases.co = "checkout";
  };

  programs.git.config.user = {
    inherit name email signingkey;
  };
}
