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

  mkDeploymentApp = name: deploy: pkgs: {
    type = "app";
    program = pkgs.writeShellApplication {
      name = "deploy-${name}";
      runtimeInputs = with pkgs; [
        nix
        nixos-rebuild
      ];
      text = ''
        privateKey="''${1:-~/.ssh/${deploy.privateKeyName}}"
        generationPath="$2"
        export NIX_SSHOPTS="-i $privateKey"
        flake="${self}"
        name="${name}"
        targetHost="${deploy.targetUser}@${deploy.targetHost}"
        extraFlags=(${escapeShellArgs (deploy.extraFlags or [ ])})

        if [[ -z "$generationPath" ]]; then
          nixos-rebuild switch --flake "$flake#$name" --target-host "$targetHost" "''${extraFlags[@]}"
        else
          nix copy --to "ssh://$targetHost" "$generationPath"
          nix run "$flake#remote-switch-$name" -- "$generationPath" "$privateKey"
        fi
      '';
    };

    meta.description = "Deploy system ${name}";
  };

  mkSwitchApp = name: deploy: pkgs: {
    type = "app";
    program = pkgs.writeShellApplication {
      name = "remote-switch-${name}";
      runtimeInputs = with pkgs; [ openssh ];
      text = ''
        generationPath="$1"
        privateKey="''${2:-"$HOME/.ssh/${deploy.privateKeyName}"}"
        targetHost="${deploy.targetUser}@${deploy.targetHost}"

        [[ -z "$generationPath" ]] && echo "Can't switch to an undefined generation" && exit 1

        # shellcheck disable=SC2087
        ssh -i "$privateKey" -T "$targetHost" << EOF
          set -e

          [[ \$EUID -ne 0 ]] && echo "Script requires root priviledges." && exit 1

          echo "Deleting home-manager backups..."
          find \$HOME -name "*.home-bac" -exec rm -rv {} +

          echo "Running switch-to-configuration switch..."
          "''${generationPath}/bin/switch-to-configuration" switch

          echo "Adding system profile..."
          NEWEST_GEN="\$(nix-env --profile /nix/var/nix/profiles/system --list-generations | awk '{ print \$1 }' | tail -n -1)";
          BUILT_GEN="\$((NEWEST_GEN + 1))"

          sudo ln -s "\$(readlink -f ''${generationPath})" "/nix/var/nix/profiles/system-\$BUILT_GEN-link"

          echo "Switching system profile..."
          nix-env --profile /nix/var/nix/profiles/system --switch-generation "\$BUILT_GEN"

          echo -e 'Done. \033[38;5;219m\U2665\033[0m'
        EOF
      '';
    };
  };
in

{
  perSystem =
    { pkgs, ... }:
    {
      apps =
        (mapAttrs' (
          name: nixosSystem:
          nameValuePair "deploy-${name}" (mkDeploymentApp name nixosSystem.config.deployment pkgs)
        ) validConfigurations)
        // (mapAttrs' (
          name: nixosSystem:
          nameValuePair "remote-switch-${name}" (mkSwitchApp name nixosSystem.config.deployment pkgs)
        ) validConfigurations)
        // {
          deploy-yuri-local = mkDeploymentApp "yuri-local" (
            validConfigurations.yuri.config.deployment
            // {
              targetHost = "10.0.0.3";
            }
          ) pkgs;
          remote-switch-yuri-local = mkSwitchApp "yuri-local" (
            validConfigurations.yuri.config.deployment
            // {
              targetHost = "10.0.0.3";
            }
          ) pkgs;
          deploy-thelessone-local = mkDeploymentApp "thelessone-local" (
            validConfigurations.thelessone.config.deployment
            // {
              targetHost = "192.168.178.84";
            }
          ) pkgs;
          remote-switch-thelessone-local = mkSwitchApp "thelessone-local" (
            validConfigurations.thelessone.config.deployment
            // {
              targetHost = "192.168.178.84";
            }
          ) pkgs;
        };
    };
}

# https://codeberg.org/Scrumplex/flake/src/commit/727020643295a9e1955496407a5c0a22bd081fc7/flakeDeploy.nix
