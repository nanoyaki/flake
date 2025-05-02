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
      runtimeInputs = with pkgs; [
        nix
        nixos-rebuild
      ];
      text = ''
        export NIX_SSHOPTS="-i ''${2:-~/.ssh/${deploy.privateKeyName}}"
        goal="''${1:-switch}"
        flake="${self}"
        name="${name}"
        targetHost="${deploy.targetUser}@${deploy.targetHost}"
        extraFlags=(${escapeShellArgs (deploy.extraFlags or [ ])})

        nix --extra-experimental-features "nix-command flakes" \
          copy --to "ssh://$targetHost" ".#nixosConfigurations.$name.config.system.build.toplevel"

        nixos-rebuild "$goal" --flake "$flake#$name" --target-host "$targetHost" "''${extraFlags[@]}"
      '';
    };

    meta.description = "Deploy system ${name}";
  };
in

{
  perSystem =
    { pkgs, ... }:
    {
      apps =
        (mapAttrs' (
          name: nixosSystem:
          nameValuePair "deploy-${name}" (mkDeploymentApp self name nixosSystem.config.deployment pkgs)
        ) validConfigurations)
        // {
          deploy-yuri-local = mkDeploymentApp self "yuri" (
            validConfigurations.yuri.config.deployment
            // {
              targetHost = "10.0.0.3";
            }
          ) pkgs;
        };
    };
}

# https://codeberg.org/Scrumplex/flake/src/commit/727020643295a9e1955496407a5c0a22bd081fc7/flakeDeploy.nix
