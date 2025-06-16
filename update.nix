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
              prefetch-yarn-deps
              curl
              jq
            ])
            ++ (with self'.packages; [
              nvchecker
            ]);
          text =
            let
              nvchecker = ''nvchecker -c source.toml -k "''${1:-/run/secrets/keys.toml}" -l debug'';
            in
            ''
              set -e

              git stash

              nix flake update
              nvfetcher -o pkgs/_sources -l /tmp/nvfetcher_changelog -k "''${1:-/run/secrets/keys.toml}"

              grep -q "suwayomi-webui" /tmp/nvfetcher_changelog \
                && ${nvchecker} -e "suwayomi-webui.revision" \
                && ${nvchecker} -e "suwayomi-webui.yarnHash"

              grep -q "suwayomi-server" /tmp/nvfetcher_changelog \
                && ${nvchecker} -e "suwayomi-server.gradleDepsHash" \
                && git add pkgs/suwayomi-server/deps.json

              grep -q "shoko-webui" /tmp/nvfetcher_changelog \
                && ${nvchecker} -e "shoko-webui.pnpmHash"

              git add pkgs/{_sources,_versions} flake.lock
              git commit -m "chore: Update $(date +"%d.%m.%y")"

              git stash pop || echo "No stash to pop."

              exit 0
            '';
        };

        meta.description = ''
          Update pkgs/{_sources,_versions} and flake.lock
        '';
      };
    };
}
