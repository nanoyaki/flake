{
  lib,
  lib',
  username,
  inputs,
  config,
  ...
}:

let
  inherit (inputs) home-manager;
in

{
  imports = [
    home-manager.nixosModules.home-manager
    (lib.modules.mkAliasOptionModule
      [ "hm" ]
      [
        "home-manager"
        "users"
        username
      ]
    )
  ];

  home-manager = {
    backupFileExtension = "home-bac";
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = { inherit lib'; };
  };

  hm = {
    home = {
      inherit username;

      homeDirectory = "/home/${username}";
      stateVersion = lib.mkDefault (
        builtins.trace "Home manager state version not set. Defaulting to system.stateVersion" config.system.stateVersion
      );
    };

    programs.home-manager.enable = true;
    xdg.enable = true;
  };
}
