{
  pkgs,
  username,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    unrar
    unzip
    p7zip

    ncdu

    gnome-disk-utility
  ];

  environment.sessionVariables.XDG_CONFIG_HOME = "/home/${username}/.config";

  # Archive manager
  programs.file-roller.enable = true;
}
