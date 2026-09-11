{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.passkey ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.passkey ];
  };

  modules.nixos.passkey =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        fido2-manage
        pam_u2f
      ];

      services.pcscd.enable = true;

      security.pam = {
        sshAgentAuth.enable = true;

        u2f.enable = true;
        u2f.settings.cue = true;

        services = {
          login.u2fAuth = true;
          sudo.u2fAuth = true;
          sudo.sshAgentAuth = true;
        };
      };
    };

  modules.nixos.sops =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.security.pam.u2f.enable {
        sops.secrets."pam/u2f".sopsFile = ./secrets.yaml;
        security.pam.u2f.settings.authfile = config.sops.secrets."pam/u2f".path;
      };
    };

  modules.nixos.openssh =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.security.pam.u2f.enable {
        programs.ssh = {
          startAgent = true;
          agentTimeout = "1h";
          askPassword = pkgs.openssh-askpass;
          extraConfig = ''
            AddKeysToAgent yes
          '';
        };
      };
    };
}
