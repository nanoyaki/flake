{ withSystem, config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.hana ];
  };

  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.hana ];
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.hana ];
  };

  modules.nixos.hana =
    { lib, config, ... }:

    let
      inherit (lib) mkMerge mkIf optional;
    in

    {
      warnings = mkIf (!(config.sops.secrets ? hana)) [
        ''
          No password file is set for user hana! Make sure to set the option
          {option}`users.users.hana.hashedPasswordFile`. Using the initial password
          "veryinsecurepassword" for now.
        ''
      ];

      users.users.hana = mkMerge [
        {
          description = "Hana";
          extraGroups = [ "wheel" ] ++ optional config.networking.networkmanager.enable "networkmanager";
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

  configurations.home."hana@himawari" = {
    imports = [ config.modules.home.hana ];

    home.stateVersion = "26.11";
  };

  configurations.home."hana@kanokoyuri" = {
    imports = [ config.modules.home.hana ];

    home.stateVersion = "24.11";
  };

  configurations.home."hana@shirayuri" = {
    imports = [ config.modules.home.hana ];

    home.stateVersion = "24.11";
  };

  modules.home.hana =
    { pkgs, config, ... }:

    {
      home.file."${config.xdg.userDirs.pictures}/hana.png".source =
        withSystem pkgs.stdenv.hostPlatform.system
          ({ config, ... }: config.legacyPackages.profile-pictures.hana);
    };

  modules.home.nix =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      config = mkIf (config.home.username == "hana") {
        programs.git.settings.user.email = "contact@nanoyaki.space";
        programs.git.settings.user.name = "nanoyaki";
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      legacyPackages.profile-pictures.hana = pkgs.fetchurl {
        name = "hana.png";
        url = "https://avatars.githubusercontent.com/u/144328493";
        hash = "sha256-ccmdcdiBVc38NP8MTGfY4z6V1dkPcH/h0X5Q4bd6904=";
      };
    };
}
