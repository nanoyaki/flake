{pkgs, ...}: {
  home.packages = with pkgs; [
    # Image manipulation
    imagemagick
    gimp
  ];

  home.file.".ssh/config".text = ''
    Host server
      User thelessone
      HostName theless.one
  '';
}
