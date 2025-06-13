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
            ])
            ++ (with self'.packages; [
              nvchecker
            ]);
          text =
            let
              nvchecker = "nvchecker -c source.toml -k /run/secrets/keys.toml";
            in
            ''
              git stash

              nix flake update
              nvfetcher -o pkgs/_sources -l /tmp/nvfetcher_changelog -k /run/secrets/keys.toml

              grep -q "suwayomi-webui" /tmp/nvfetcher_changelog \
                && ${nvchecker} -e "suwayomi-webui.revision" \
                && ${nvchecker} -e "suwayomi-webui.yarnHash"

              grep -q "suwayomi-server" /tmp/nvfetcher_changelog \
                && ${nvchecker} -e "suwayomi-server.gradleDepsHash" \
                && git add pkgs/suwayomi-server/deps.json

              git add pkgs/{_sources,versions.json} flake.lock
              git commit -m "chore: Update $(date +"%d.%m.%y")"

              git stash pop
            '';
        };

        meta.description = ''
          Update pkgs/{_sources,versions.json} and flake.lock
        '';
      };
    };
}
