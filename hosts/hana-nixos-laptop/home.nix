{...}: {
  home.file.".ssh/config".text = ''
    Host server
      User thelessone
      HostName theless.one
  '';
}
