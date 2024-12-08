let
  name = "nanoyaki";
  email = "hanakretzer@gmail.com";
in

{
  hm.programs.git = {
    userName = name;
    userEmail = email;
  };

  programs.git.config.user = {
    inherit name email;
  };
}
