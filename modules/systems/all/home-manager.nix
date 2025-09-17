{
  lib,
  lib',
  self,
  self',
  inputs,
  config,
  pkgs,
  ...
}:

let
  inherit (lib)
    mapAttrs
    filterAttrs
    attrNames
    mkAliasOptionModule
    ;
  inherit (inputs) home-manager;

  sharedAlias = mkAliasOptionModule [ "hms" ] [ "home-manager" "sharedModules" ];
  mainHomeConfigAlias =
    mkAliasOptionModule
      [ "hm" ]
      [ "home-manager" "users" config.config'.mainUserName ];
in

{
  imports = [
    home-manager.nixosModules.home-manager
    sharedAlias
    mainHomeConfigAlias
  ];

  assertions = [
    {
      assertion =
        (attrNames (filterAttrs (_: user: user.home.stateVersion == "") config.config'.users)) == [ ];
      message = "home.stateVersion must be set";
    }
  ];

  home-manager = {
    backupFileExtension = "home-bac";
    useUserPackages = true;
    useGlobalPkgs = true;
    verbose = true;

    extraSpecialArgs = { inherit self self' lib'; };
    sharedModules = [
      self.homeManagerModules.symlinks
      {
        programs.home-manager.enable = true;
        home.shell.enableShellIntegration = true;
        home.preferXdgDirectories = true;
        xdg.enable = true;
      }
    ];

    users = mapAttrs (username: user: {
      home = {
        inherit username;
        inherit (user.home) stateVersion;
      };
    }) config.config'.users;
  };

  hms = lib.singleton {
    home.activation.deleteHmBackups = config.hm.lib.dag.entryBefore [ "checkLinkTargets" ] ''
      run ${lib.getExe pkgs.findutils} $HOME \
          ! -readable -prune -o \
          -readable -name "*.home-bac" -exec rm -rf {} + || true
    '';
  };
}
