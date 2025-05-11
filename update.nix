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
            nvchecker
            nvfetcher
            git
            prefetch-yarn-deps
          ];
          text = ''
            nix --extra-experimental-features "nix-command flakes" flake update
            nvfetcher -o pkgs/_sources "$@"
            nvchecker -c nvchecker.toml

            git stash

            git add pkgs/{_sources,_versions} flake.lock
            git commit -m "chore: Update $(date +"%d.%m.%y")"

            git stash pop
          '';
        };

        meta.description = ''
          Update pkgs/{_sources,_versions} and flake.lock
        '';
      };
    };
}
