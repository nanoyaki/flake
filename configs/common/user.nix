{
  lib',
  username,
  config,
  ...
}:

{
  sec."nixos/users/${username}".neededForUsers = true;

  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    description = lib'.toUppercase username;
    hashedPasswordFile = config.sec."nixos/users/${username}".path;
    extraGroups = [ "wheel" ];
  };

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
