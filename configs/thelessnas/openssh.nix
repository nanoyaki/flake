{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = true;
  };
}
