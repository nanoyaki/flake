{
  perSystem =
    { pkgs, ... }:
    {
      apps.update = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = with pkgs; [
            nix
            nvfetcher
            git
            prefetch-yarn-deps
            curl
          ];
          text = ''
            git stash

            nix flake update
            nvfetcher -o pkgs/_sources -l /tmp/nvfetcher_changelog -k /run/secrets/keys.toml

            grep -q "suwayomi-webui" /tmp/nvfetcher_changelog \
              && nix run .#updateVersions -- "suwayomi-webui" "revision" \
              && nix run .#updateVersions -- "suwayomi-webui" "yarnHash"

            grep -q "suwayomi-server" /tmp/nvfetcher_changelog \
              && nix run .#updateVersions -- "suwayomi-server" "gradleDepsHash"

            git add pkgs/{_sources,versions.json} flake.lock
            git commit -m "chore: Update $(date +"%d.%m.%y")"

            git stash pop
          '';
        };

        meta.description = ''
          Update pkgs/{_sources,versions.json} and flake.lock
        '';
      };

      apps.updateVersions = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "updateVersions";
          runtimeInputs = with pkgs; [
            yq
            jq
          ];
          text = ''
            project="$1"
            key="$2"
            shift 2

            echo "Updating key $key of project $project"

            cmd="$(tomlq ".\"$project\".\"$key\".script" versions.toml -r)"
            version="$(sh -c "$cmd" 2> /dev/null)"

            versionFile="$(tomlq ".config.file" versions.toml -r)"
            jq ".\"$project\".\"$key\"=\"$version\"" "$versionFile" > /tmp/versions.json \
              && mv /tmp/versions.json "$versionFile"

            echo "Updated key $key of project $project to $version"
          '';
        };

        meta.description = ''
          Update a project's version informations in pkgs/versions.json
        '';
      };
    };
}
