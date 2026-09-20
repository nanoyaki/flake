{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.openssh ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.openssh ];
  };

  modules.nixos.openssh =
    { lib, pkgs, ... }:

    let
      inherit (lib) mkDefault;
    in

    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        startWhenNeeded = true;

        settings = {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = lib.mkDefault false;
          KexAlgorithms = [
            "mlkem768x25519-sha256"
            "sntrup761x25519-sha512"
            "sntrup761x25519-sha512@openssh.com"
          ];
        };
      };

      systemd.services.sshd.unitConfig.DefaultDependencies = false;
      systemd.services.sshd.serviceConfig.Restart = "always";

      users.users.root.openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTdis9sEaWC/dHRq6a5sTrcBQmQuDQ+OxzJQuhnx/daAAAABHNzaDo= id_nadesiko"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFRFwcPIHwwoaGk+SOQITBgdWZoLsBuYnwpiWJcf78uzAAAAC3NzaDpkZWZhdWx0 id_hasu"
      ];

      programs.ssh = {
        startAgent = mkDefault true;
        agentTimeout = "1h";
        askPassword = pkgs.openssh-askpass.outPath;
        extraConfig = ''
          AddKeysToAgent yes
        '';
      };
    };

  modules.nixos.niri =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf config.services.openssh.enable {
        programs.ssh.enableAskPassword = true;
        programs.ssh.startAgent = false;
      };
    };
}
