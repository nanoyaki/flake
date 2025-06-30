{
  perSystem =
    { pkgs, self', ... }:
    {
      apps.update = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs =
            (with pkgs; [
              nix
              nvfetcher
              git
              curl
              jq
              gnused
              gawk
              findutils
            ])
            ++ (with self'.packages; [
              nvchecker
            ]);
          text =
            let
              nvchecker = ''nvchecker -c source.toml -k "''${1:-/run/secrets/keys.toml}" -l debug --failures -e'';
            in
            ''
              set -e

              git stash

              nix flake update
              nvfetcher -o pkgs/_sources -l /tmp/nvfetcher_changelog -k "''${1:-/run/secrets/keys.toml}"

              grep -q "suwayomi-webui" /tmp/nvfetcher_changelog \
                && ${nvchecker} "suwayomi-webui.revision" \
                && ${nvchecker} "suwayomi-webui.yarnHash"

              grep -q "suwayomi-server" /tmp/nvfetcher_changelog \
                && ${nvchecker} "suwayomi-server.gradleDepsHash" \
                && ${nvchecker} "suwayomi-server.version"

              grep -q "shoko:" /tmp/nvfetcher_changelog \
                && ${nvchecker} "shoko.nugetDepsHash"

              grep -q "shoko-webui" /tmp/nvfetcher_changelog \
                && ${nvchecker} "shoko-webui.pnpmHash"

              grep -q "shokofin" /tmp/nvfetcher_changelog \
                && ${nvchecker} "shokofin.nugetDepsHash"

              nvcmp -c source.toml | sed 's|->|→|g' > /tmp/nvchecker_changelog

              git add pkgs/{_sources,_versions,*/deps.json} flake.lock update*
              git commit -m "chore: Update $(date +"%d.%m.%y")

              $(cat /tmp/nvfetcher_changelog)
              $(cat /tmp/nvchecker_changelog)"

              git stash pop || echo "No stashed changes."

              exit 0
            '';
        };

        meta.description = ''
          Update pkgs/{_sources,_versions} and flake.lock
        '';
      };

      apps.update-pkg = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update-pkg";
          runtimeInputs = [ pkgs.nix ];
          text = ''
            nix-shell "$(nix eval nixpkgs\#pkgs.path)/maintainers/scripts/update.nix" \
              --arg include-overlays "[ (builtins.getFlake \"$FLAKE_DIR\").overlays.default ]" \
              --argstr path "$1"
          '';
        };

        meta.description = ''
          Run nixpkgs update scripts for overlayed packages
        '';
      };
    };
}
