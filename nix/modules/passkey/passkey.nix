{
  flake.nixosModules.passkey =
    { pkgs, config, ... }:

    {
      environment.systemPackages = with pkgs; [
        # yubikey-manager
        fido2-manage
        pam_u2f
      ];

      services.pcscd.enable = true;
      # Since I'm using hasu at the moment
      # services.udev.packages = [ pkgs.yubikey-personalization ];
      # services.yubikey-agent.enable = true;

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

      sops.secrets."pam/u2f" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        owner = config.self.mainUser;
        mode = "400";
      };

      security.pam.sshAgentAuth.enable = true;

      security.pam.u2f.enable = true;
      security.pam.u2f.settings = {
        interactive = true;
        cue = true;
        authfile = config.sops.secrets."pam/u2f".path;
      };

      security.pam.services = {
        login.u2fAuth = true;

        sudo.u2fAuth = true;
        sudo.sshAgentAuth = true;
      };
    };

  flake.homeModules.passkey =
    { config, ... }:

    {
      sops.secrets."ssh/id_nadesiko" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        path = "${config.home.homeDirectory}/.ssh/id_nadesiko";
        mode = "400";
      };

      sops.secrets."ssh/id_hasu" = {
        sopsFile = ./yuri.yaml;
        format = "yaml";
        path = "${config.home.homeDirectory}/.ssh/id_hasu";
        mode = "400";
      };

      home.file."${config.home.homeDirectory}/.ssh/id_nadesiko.pub".source = ./id_nadesiko.pub;
      home.file."${config.home.homeDirectory}/.ssh/id_hasu.pub".source = ./id_hasu.pub;
    };
}
