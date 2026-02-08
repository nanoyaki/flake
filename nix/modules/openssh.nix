{
  flake.nixosModules.openssh =
    { config, ... }:

    let
      id_nadesiko = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTdis9sEaWC/dHRq6a5sTrcBQmQuDQ+OxzJQuhnx/daAAAABHNzaDo=";
    in

    {
      services.openssh = {
        enable = true;
        openFirewall = true;

        settings.PermitRootLogin = "prohibit-password";
        settings.PasswordAuthentication = false;
      };

      systemd.services.sshd = {
        unitConfig.DefaultDependencies = false;
        serviceConfig.Restart = "always";
      };

      services.fail2ban = {
        enable = true;
        maxretry = 5;
        bantime-increment.enable = true;
      };

      users.users.root.openssh.authorizedKeys.keys = [ id_nadesiko ];
      users.users.${config.self.mainUser}.openssh.authorizedKeys.keys = [ id_nadesiko ];
    };
}
