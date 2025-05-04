{
  pkgs,
  config,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    yubioath-flutter
    yubikey-manager
    pam_u2f
  ];

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  hardware.gpgSmartcards.enable = true;

  services.yubikey-agent.enable = true;

  security.pam = {
    sshAgentAuth.enable = true;

    u2f = {
      enable = true;
      settings = {
        cue = false;
        authfile = "${config.hm.xdg.configHome}/Yubico/u2f_keys";
      };
    };

    services = {
      login.u2fAuth = true;
      sudo = {
        u2fAuth = true;
        sshAgentAuth = true;
      };
    };
  };

  programs.ssh.extraConfig = ''
    AddKeysToAgent yes
  '';
}
