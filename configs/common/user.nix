{
  nLib,
  username,
  config,
  ...
}:

{
  sec."nixos/users/${username}".owner = username;

  users.users.${username} = {
    isNormalUser = true;
    description = nLib.toUppercase username;
    hashedPasswordFile = config.sec."nixos/users/${username}".path;
    extraGroups = [ "wheel" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "${username}" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
