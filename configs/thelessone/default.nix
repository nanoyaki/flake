{
  deps,
  self,
  inputs,
  ...
}:

{
  flake = {
    nixosConfigurations = deps.mkSystem {
      hostname = "thelessone";
      username = "thelessone";
      modules = [
        ../common/sops.nix
        ../common/home.nix
        ../common/nix.nix
        ../common/user.nix
        ../common/networking.nix
        ../common/audio.nix
        ../common/input.nix
        ../common/programming.nix
        ../common/shell.nix

        ./hardware

        ./firewall.nix
        ./gnome.nix
        ./configuration.nix
        ./git.nix
        ./locale.nix
        ./servers
        ./terminal.nix
        # ./mullvad.nix
      ];
    };

    deploy.nodes.thelessone = {
      hostname = "theless.one";
      sshUser = "thelessone";
      sshOpts = [
        "-i"
        self.nixosConfigurations.thelessone.config.sec."deployment/private".path
      ];
      remoteBuild = true;

      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.thelessone;
      };
    };

    checks = builtins.mapAttrs (
      system: deployLib: deployLib.deployChecks self.deploy
    ) inputs.deploy-rs.lib;
  };
}
