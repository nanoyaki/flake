{pkgs, ...}: {
  home.packages = with pkgs; [
    # Image manipulation
    imagemagick
    gimp
  ];

  programs.ssh.extraConfig = ''
    Host GitHub
      HostName github.com
      IdentityFile ~/.ssh/id_rsa_gh
  '';
}
