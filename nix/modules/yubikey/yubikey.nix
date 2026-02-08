{
  flake.nixosModules.yubikey =
    { pkgs, config, ... }:

    {
      environment.systemPackages = with pkgs; [
        yubikey-manager
        pam_u2f
      ];

      services.pcscd.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];
      hardware.gpgSmartcards.enable = true;

      services.yubikey-agent.enable = true;
      security.pam.sshAgentAuth.enable = true;

      services.gnome.gcr-ssh-agent.enable = false;
      programs.ssh = {
        startAgent = true;
        agentTimeout = "1h";
        askPassword =
          if config.services.desktopManager.plasma6.enable then
            pkgs.kdePackages.ksshaskpass
          else
            pkgs.openssh-askpass;
        extraConfig = ''
          AddKeysToAgent yes
        '';
      };

      sops.secrets."yubikeys/u2f_keys" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        owner = config.self.mainUser;
        mode = "400";
      };

      security.pam.u2f = {
        enable = true;
        settings = {
          cue = true;
          authfile = config.sops.secrets."yubikeys/u2f_keys".path;
        };
      };

      security.pam.services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true;
        };
      };
    };

  flake.homeModules.yubikey =
    { pkgs, ... }:

    {
      programs.gpg = {
        enable = true;
        scdaemonSettings.disable-ccid = true;
      };

      services.gpg-agent = {
        enable = true;
        pinentry = {
          package = pkgs.pinentry-tty;
          program = "pinentry";
        };
      };

      sops.secrets."private_keys/id_nadesiko" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        path = ".ssh/id_nadesiko";
      };

      home.file.".ssh/id_nadesiko.pub".source = ./id_nadesiko.pub;
    };
}
