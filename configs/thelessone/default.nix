{
  lib',
  ...
}:

{
  flake.nixosConfigurations.thelessone = lib'.mkDesktop {
    hostname = "thelessone";
    users = {
      thelessone = {
        mainUser = true;
        isSuperuser = true;
        home.stateVersion = "24.11";
      };
      root.home.stateVersion = "25.11";
    };
    config = {
      imports = [
        ./hardware
        ./networking

        ./configuration.nix
        ./git.nix
        ./servers
        ./terminal.nix
        # ./beets.nix
      ];

      networking.hostId = "f617b7b6";
      system.stateVersion = "24.11";
    };
  };
}
