{
  pkgs,
  username,
  ...
}:

{
  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [ nix ];

    stateVersion = "25.05";

    shell.enableShellIntegration = true;
    shellAliases.rb = "home-manager switch --flake $FLAKE_DIR";
    sessionVariables.FLAKE_DIR = "/home/hana/flake";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    autostart.enable = true;
  };
}
