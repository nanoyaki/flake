{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.hana ];
  };

  modules.nixos.hana =
    { lib, config, ... }:

    let
      inherit (lib) mkMerge mkIf;
    in

    {
      warnings = mkIf (!(config.sops.secrets ? hana)) [
        ''
          No password file is set for user hana! Make sure to set the option
          {option}`users.users.hana.hashedPasswordFile`. Using the initial password
          "veryinsecurepassword".
        ''
      ];

      users.users.hana = mkMerge [
        {
          description = "Hana";
          extraGroups = [ "wheel" ];
          isNormalUser = true;
        }
        (mkIf (config.sops.secrets ? hana) {
          hashedPasswordFile = config.sops.secrets.hana.path;
        })
        (mkIf (!(config.sops.secrets ? hana)) {
          initialPassword = "veryinsecurepassword";
        })
        (mkIf config.services.openssh.enable {
          openssh.authorizedKeys.keys = [
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGTdis9sEaWC/dHRq6a5sTrcBQmQuDQ+OxzJQuhnx/daAAAABHNzaDo= id_nadesiko"
            "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFRFwcPIHwwoaGk+SOQITBgdWZoLsBuYnwpiWJcf78uzAAAAC3NzaDpkZWZhdWx0 id_hasu"
          ];
        })
      ];
    };

  modules.nixos.sops = {
    sops.secrets.hana = {
      sopsFile = ./secrets.yaml;
      neededForUsers = true;
    };
  };

  configurations.home."hana@kanokoyuri" = {
    home.homeDirectory = "/home/hana";
    home.stateVersion = "24.11";
    home.username = "hana";
  };
}
