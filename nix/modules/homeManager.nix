{ inputs, ... }:

{
  flake.nixosModules.homeManager =
    { lib, ... }:

    {
      imports = [ inputs.home-manager.nixosModules.default ];

      home-manager = {
        verbose = true;
        backupFileExtension = "hmbac";
        overwriteBackup = lib.mkDefault true;
        useUserPackages = true;
        useGlobalPkgs = true;
      };
    };

  flake.homeModules.homeManager = {
    programs.home-manager.enable = true;

    xdg.enable = true;
    home.preferXdgDirectories = true;
    home.shell.enableBashIntegration = true;
  };

  imports = [ inputs.home-manager.flakeModules.home-manager ];
}
