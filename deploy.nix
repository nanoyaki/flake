{
  self,
  lib,
  ...
}:

let
  inherit (lib)
    escapeShellArgs
    filterAttrs
    mapAttrs'
    nameValuePair
    ;

  validConfigurations = filterAttrs (
    _: nixosSystem: nixosSystem.options ? deployment
  ) self.nixosConfigurations;

  mkDeploymentApp = self: name: deploy: pkgs: {
    type = "app";
    program = pkgs.writeShellApplication {
      name = "deploy-${name}";
      runtimeInputs = with pkgs; [ nixos-rebuild ];
      text = ''
        export NIX_SSHOPTS="-i ''${2:-~/.ssh/${deploy.privateKeyName}}"
        goal="''${1:-switch}"
        flake="${self}"
        name="${name}"
        targetHost="${deploy.targetUser}@${deploy.targetHost}"
        extraFlags=(${escapeShellArgs (deploy.extraFlags or [ ])})

        nixos-rebuild "$goal" --flake "$flake#$name" --target-host "$targetHost" "''${extraFlags[@]}"
      '';
    };
  };
in

{
  perSystem =
    { pkgs, ... }:
    {
      apps = mapAttrs' (
        name: nixosSystem:
        nameValuePair "deploy-${name}" (mkDeploymentApp self name nixosSystem.config.deployment pkgs)
      ) validConfigurations;
    };
}

# https://codeberg.org/Scrumplex/flake/src/commit/727020643295a9e1955496407a5c0a22bd081fc7/flakeDeploy.nix
