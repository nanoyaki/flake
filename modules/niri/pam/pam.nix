{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.pam ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.pam ];
  };

  modules.nixos.pam = {
    security.pam.enable = true;
  };

  modules.nixos.passkey =
    { pkgs, ... }:

    {
      environment.systemPackages = [ pkgs.pam_u2f ];

      security.pam = {
        u2f.enable = true;
        u2f.settings.cue = true;

        services.login.u2fAuth = true;
        services.sudo.u2fAuth = true;
      };
    };

  modules.nixos.openssh =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.security.pam.enable {
        security.pam.sshAgentAuth.enable = true;
        security.pam.services.sudo.sshAgentAuth = true;
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

  modules.nixos.oo7 =
    { lib, config, ... }:

    let
      inherit (lib) mkIf mkForce;
    in

    {
      config = mkIf config.security.pam.enable {
        security.pam.services = {
          login.oo7.enable = true;
          login.enableGnomeKeyring = mkForce false;

          greetd.oo7.enable = true;
          greetd.enableGnomeKeyring = mkForce false;
        };
      };
    };

  modules.nixos.niri =
    { lib, config, ... }:

    let
      inherit (lib) mkIf mkDefault;
    in

    {
      config = mkIf config.security.pam.enable {
        security.pam.services.login.enableGnomeKeyring = mkDefault true;
        security.pam.services.greetd.enableGnomeKeyring = mkDefault true;
      };
    };
}
