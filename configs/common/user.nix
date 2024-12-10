{
  nLib,
  username,
  config,
  ...
}:

{
  users.users.${username} = {
    isNormalUser = true;
    description = nLib.toUppercase username;
    hashedPasswordFile = config.sops.secrets."nixos/users/${username}".path;
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
