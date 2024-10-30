{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Hana";
    extraGroups = [
      "wheel"
      "input"
      "audio"
      "uinput"
      "jackaudio"
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
