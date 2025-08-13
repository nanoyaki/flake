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

        ./firewall.nix
        ./configuration.nix
        ./git.nix
        ./servers
        ./terminal.nix
        ./deployment.nix
        ./vaultwarden.nix
        ./beets.nix
        ./fireqos.nix
      ];

      networking.hostId = "f617b7b6";
      system.stateVersion = "24.11";
    };
  };
}
