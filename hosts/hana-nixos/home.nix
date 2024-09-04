{pkgs, ...}: {
  home.packages = with pkgs; [
    # Image manipulation
    imagemagick
    gimp
  ];

  home.file.".ssh/config".text = ''
    Host GitHub
      HostName github.com
      IdentityFile ~/.ssh/id_rsa_gh
  '';
}
