{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
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
