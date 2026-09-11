{
  inputs,
  self,
  lib,
  config,
  moduleLocation,
  ...
}:

let
  inherit (builtins) elemAt;
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
    default = { };
  };

  config = {
    flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

    flake.homeConfigurations = mapAttrs (
      userAtHost: module:

      let
        hostname = elemAt (splitString "@" userAtHost) 1;
      in

      inputs.home-manager.lib.homeManagerConfiguration (
        {
          modules = [
            {
              _class = "homeManager";
              _file = "${toString moduleLocation}#configurations.home.${userAtHost}";
              imports = [ module ];
            }
          ];
        }
        // (optionalAttrs (config.configurations.nixos ? ${hostname}) {
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
          parts = (splitString "@" userAtHost);
          username = elemAt parts 0;
          hostname = elemAt parts 1;
        in

        {
          ${hostname} =
            { lib, config, ... }:

            {
              config = lib.mkIf (config ? home-manager) {
                home-manager.users.${username}.imports = [ module ];
              };
            };
        }
      ) config.configurations.home)
      ++ [
        { kanokoyuri.imports = [ config.modules.nixos.home-manager ]; }
        { himawari.imports = [ config.modules.nixos.home-manager ]; }
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

    modules.home.home-manager = {
      xdg.enable = true;
      home.preferXdgDirectories = true;

      home.shell.enableBashIntegration = true;
      programs.home-manager.enable = true;
    };
  };
}
