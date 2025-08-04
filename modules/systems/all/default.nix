{
  hostname,
  users,
  platform,
}:

{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mapAttrs
    mkIf
    filterAttrs
    attrNames
    length
    elemAt
    ;
  inherit (lib'.options)
    mkSubmoduleOption
    mkNullOr
    mkFalseOption
    mkAttrsOf
    mkStrOption
    mkEnumOption
    ;
in

{
  imports = [
    ./sops.nix
    ./boot.nix
    ./git.nix
    ./nix.nix
    ./home-manager.nix
    ./inputs.nix
    ./shell.nix
    ./locale.nix
    ./ssh.nix
  ];

  options.config' = {
    users = mkAttrsOf (mkSubmoduleOption {
      mainUser = mkFalseOption;
      isSuperuser = mkFalseOption;
      sopsKey = mkNullOr mkStrOption;
      home.stateVersion = mkStrOption;
    });
    mainUserName = mkStrOption;
    systemType = mkEnumOption [
      "headless"
      "portable"
      "desktop"
      "server"
    ];
  };

  config = {
    assertions = [
      {
        assertion =
          (length (attrNames (filterAttrs (_: user: user ? mainUser && user.mainUser) users))) == 1;
        message = "Only one user can be the main user and at least one user has to be the main user";
      }
    ];

    environment.systemPackages = [ pkgs.libargon2 ];

    config'.users = mapAttrs (
      username: user:
      user
      // (lib.optionalAttrs (!(user ? sopsKey) || user.sopsKey == null) {
        sopsKey = "users/${username}";
      })
      // (lib.optionalAttrs (username == "root") { isSuperuser = true; })
    ) users;
    config'.mainUserName = elemAt (attrNames (
      filterAttrs (_: user: user.mainUser) config.config'.users
    )) 0;

    users.mutableUsers = false;
    users.users = mapAttrs (username: user: {
      isNormalUser = true;
      description = lib'.toUppercase username;
      extraGroups = mkIf user.isSuperuser [ "wheel" ];
    }) (filterAttrs (username: _: username != "root") config.config'.users);

    networking.hostName = hostname;
    nixpkgs.hostPlatform.system = platform;

    networking.useDHCP = lib.mkDefault true;
  };
}
