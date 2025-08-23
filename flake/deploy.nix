{
  self,
  lib,
  ...
}:

let
  inherit (lib)
    filterAttrs
    flatten
    listToAttrs
    attrNames
    replaceString
    ;

  validConfigurations = filterAttrs (
    _: nixosSystem: nixosSystem.options ? config'.deployment
  ) self.nixosConfigurations;

  mkDeploymentApp = name: cfg: host: pkgs: {
    type = "app";
    program = pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [
        nix
        nixos-rebuild
      ];
      text = ''
        set -x

        generationPath="$1"
        flake="${self}"
        name="${name}"
        targetHost="${cfg.targetUser}@${host}"
        id="''${2:-}"

        [[ -n "$id" ]] && export NIX_SSHOPTS="-i $id"
        if [[ -z "$generationPath" ]]; then
          nixos-rebuild switch --flake "$flake#$name" --target-host "$targetHost"
        else
          nix copy --to "ssh://$targetHost" "$generationPath"
          nix run "$flake#switch-${replaceString "." "-" host}" -- "$generationPath" "$id"
        fi
      '';
    };

    meta.description = "Deploy system ${name}";
  };

  mkSwitchApp = name: cfg: host: pkgs: {
    type = "app";
    program = pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [ openssh ];
      text = ''
        set -x

        generationPath="$1"
        targetHost="${cfg.targetUser}@${host}"
        sshOpts=(-T "$targetHost")
        if [[ -n $2 ]]; then
            sshOpts=(-i "$2" "''${sshOpts[@]}")
        fi

        [[ -z "$generationPath" ]] && echo "Can't switch to an undefined generation" && exit 1

        # shellcheck disable=SC2087
        ssh "''${sshOpts[@]}" << EOF
          set -e

          [[ \$EUID -ne 0 ]] && echo "Script requires root priviledges." && exit 1

          echo "Deleting home-manager backups..."
          find \$HOME -name "*.home-bac" -exec rm -rv {} +

          echo "Running switch-to-configuration switch..."
          "''${generationPath}/bin/switch-to-configuration" switch

          echo "Adding system profile..."
          NEWEST_GEN="\$(nix-env --profile /nix/var/nix/profiles/system --list-generations | awk '{ print \$1 }' | tail -n -1)";
          BUILT_GEN="\$((NEWEST_GEN + 1))"

          ln -s "\$(readlink -f ''${generationPath})" "/nix/var/nix/profiles/system-\$BUILT_GEN-link"

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
      apps = listToAttrs (
        flatten (
          map (
            name:
            let
              deployCfgs = validConfigurations.${name}.config.config'.deployment;
              hosts = attrNames deployCfgs;
            in
            (map (host: rec {
              name = "deploy-${replaceString "." "-" host}";
              value = mkDeploymentApp name deployCfgs.${host} host pkgs;
            }) hosts)
            ++ (map (host: rec {
              name = "switch-${replaceString "." "-" host}";
              value = mkSwitchApp name deployCfgs.${host} host pkgs;
            }) hosts)
          ) (attrNames validConfigurations)
        )
      );
      # (
      #   mapAttrs' (
      #     name: nixosSystem:
      #     nameValuePair "deploy-${name}" (mkDeploymentApp name nixosSystem.config.deployment pkgs)
      #   ) validConfigurations
      # )
      # // (mapAttrs' (
      #   name: nixosSystem:
      #   nameValuePair "remote-switch-${name}" (mkSwitchApp name nixosSystem.config.deployment pkgs)
      # ) validConfigurations);
    };
}

# https://codeberg.org/Scrumplex/flake/src/commit/727020643295a9e1955496407a5c0a22bd081fc7/flakeDeploy.nix
