{...}: {
  home.file.".ssh/config" = ''
    Host server
      User thelessone
      HostName theless.one
  '';
}
