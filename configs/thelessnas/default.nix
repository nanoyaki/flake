{
  lib',
  ...
}:

{
  flake.nixosConfigurations.thelessnas = lib'.mkServer {
    hostname = "thelessnas";
    users.admin = {
      mainUser = true;
      isSuperuser = true;
      home.stateVersion = "25.11";
    };
    config = {
      imports = [
        ./hardware

        ./configuration.nix
        ./openssh.nix
        ./deployment.nix
        ./zfs.nix
      ];

      system.stateVersion = "24.11";
    };
  };
}
