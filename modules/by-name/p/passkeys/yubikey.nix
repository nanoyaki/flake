{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

{
  options.config'.yubikey.enable = lib'.options.mkFalseOption;

  config = lib.mkIf config.config'.yubikey.enable {
    environment.systemPackages = with pkgs; [
      yubikey-manager
      pam_u2f
    ];

    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
    hardware.gpgSmartcards.enable = true;

    services.yubikey-agent.enable = true;

    security.pam.sshAgentAuth.enable = true;

    programs.ssh = {
      startAgent = true;
      agentTimeout = "1h";
      askPassword = lib.mkIf config.services.desktopManager.plasma6.enable pkgs.kdePackages.ksshaskpass;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    hms = lib.singleton {
      programs.gpg = {
        enable = true;
        scdaemonSettings.disable-ccid = true;
      };

      services.gpg-agent = {
        enable = true;
        pinentry = {
          package = pkgs.pinentry-qt;
          program = "pinentry";
        };
      };
    };
  };
}
