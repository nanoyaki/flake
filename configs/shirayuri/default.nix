{ self, lib', ... }:

{
  flake.nixosConfigurations.shirayuri = lib'.mkDesktop {
    hostname = "shirayuri";
    users.hana = {
      mainUser = true;
      isSuperuser = true;
      home.stateVersion = "24.11";
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
      ];

      system.stateVersion = "24.11";
    };
  };
}
