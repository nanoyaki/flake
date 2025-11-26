let
  name = "nanoyaki";
  email = "hanakretzer@gmail.com";
in

{
  hm.programs.git.settings.user = {
    inherit name email;
  };

  programs.git.config.user = {
    inherit name email;
  };
}
