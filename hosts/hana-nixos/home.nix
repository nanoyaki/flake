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

    Host Thelessone
      HostName theless.one
      IdentityFile ~/.ssh/id_ed25519
  '';
}
