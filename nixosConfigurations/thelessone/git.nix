let
  name = "thelessone";
  email = "hanakretzer+thelessone@gmail.com";
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
