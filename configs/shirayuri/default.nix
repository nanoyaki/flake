{ self, lib', ... }:

{
  flake.nixosConfigurations.shirayuri = lib'.mkDesktop {
    hostname = "shirayuri";
    users = {
      hana = {
        mainUser = true;
        isSuperuser = true;
        home.stateVersion = "24.11";
      };
      root.home.stateVersion = "25.11";
    };
    config = {
      imports = [
        ./hardware

        self.nixosModules.vr
        ./configuration.nix
        ./xdg.nix
        ./gaming
        ./git.nix
        ./ssh.nix
        ./backup.nix
      ];

      system.stateVersion = "24.11";
    };
  };
}
