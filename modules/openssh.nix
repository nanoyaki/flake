{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.openssh ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.openssh ];
  };

  modules.nixos.openssh =
    { lib, ... }:

    {
      services.openssh = {
        enable = true;
        openFirewall = true;

        settings.PermitRootLogin = "prohibit-password";
        settings.PasswordAuthentication = lib.mkDefault false;
      };

      systemd.services.sshd = {
        unitConfig.DefaultDependencies = false;
        serviceConfig.Restart = "always";
      };

      users.users.root.openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTdis9sEaWC/dHRq6a5sTrcBQmQuDQ+OxzJQuhnx/daAAAABHNzaDo= id_nadesiko"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFRFwcPIHwwoaGk+SOQITBgdWZoLsBuYnwpiWJcf78uzAAAAC3NzaDpkZWZhdWx0 id_hasu"
      ];
    };
}
