{
  inputs,
  self,
  lib,
  config,
  moduleLocation,
  ...
}:

let
  inherit (builtins) head elemAt;
  inherit (lib)
    mkOption
    types
    mapAttrs
    mapAttrsToList
    optionalAttrs
    splitString
    mkMerge
    ;
in

{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  options.modules.home = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    apply = mapAttrs (
      name: module: {
        _class = "homeManager";
        _file = "${toString moduleLocation}#modules.home.${name}";
        imports = [ module ];
      }
    );
    default = { };
  };

  options.configurations.home = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    apply = mapAttrs (
      name: module: {
        _class = "homeManager";
        _file = "${toString moduleLocation}#configurations.home.${name}";
        imports = [ module ];
      }
    );
    default = { };
  };

  config = {
    flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

    flake.homeConfigurations = mapAttrs (
      userAtHost: module:

      let
        username = head (splitString "@" userAtHost);
        hostname = elemAt (splitString "@" userAtHost) 1;
      in

      inputs.home-manager.lib.homeManagerConfiguration (
        {
          modules = [
            (
              { lib, ... }:

              let
                inherit (lib) mkDefault;
              in

              {
                home.username = mkDefault username;
                home.homeDirectory = mkDefault "/home/${username}";
              }
            )
            module
          ];
        }
        // (optionalAttrs (config ? configurations.nixos.${hostname}) {
          pkgs = import inputs.nixpkgs {
            inherit (self.nixosConfigurations.${hostname}.config.nixpkgs.hostPlatform) system;
            inherit (self.nixosConfigurations.${hostname}.config.nixpkgs)
              overlays
              config
              ;
          };
        })
      )
    ) config.configurations.home;

    configurations.nixos = mkMerge (
      (mapAttrsToList (
        userAtHost: module:

        let
          username = head (splitString "@" userAtHost);
          hostname = elemAt (splitString "@" userAtHost) 1;
        in

        {
          ${hostname} =
            { lib, options, ... }:

            {
              config = lib.mkIf (options ? home-manager) {
                home-manager.users.${username}.imports = [
                  (
                    { lib, ... }:

                    let
                      inherit (lib) mkDefault;
                    in

                    {
                      home.username = mkDefault username;
                      home.homeDirectory = mkDefault "/home/${username}";
                    }
                  )
                  module
                ];
              };
            };
        }
      ) config.configurations.home)
      ++ [
        {
          kanokoyuri = {
            imports = [ config.modules.nixos.home-manager ];
          };

          himawari = {
            imports = [ config.modules.nixos.home-manager ];
          };

          shirayuri = {
            imports = [ config.modules.nixos.home-manager ];
          };
        }
      ]
    );

    modules.nixos.home-manager = {
      imports = [ inputs.home-manager.nixosModules.default ];

      home-manager = {
        verbose = true;
        backupFileExtension = "hmbac";
        useUserPackages = true;
        useGlobalPkgs = true;
      };
    };

    configurations.home."hana@kanokoyuri" = {
      imports = [ config.modules.home.home-manager ];
    };

    configurations.home."hana@himawari" = {
      imports = [ config.modules.home.home-manager ];
    };

    configurations.home."hana@shirayuri" = {
      imports = [ config.modules.home.home-manager ];
    };

    modules.home.home-manager = {
      xdg.enable = true;
      home.preferXdgDirectories = true;

      home.shell.enableShellIntegration = true;
      programs.home-manager.enable = true;
    };
  };
}
