{ username, config, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
    hashedPasswordFile = config.sops.secrets."users/hana/password".path;
    extraGroups = [
      "wheel"
      "input"
      "uinput"
    ];
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
