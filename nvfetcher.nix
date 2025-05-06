{
  perSystem =
    { pkgs, ... }:
    {
      apps.nvfetcher = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "nvfetcher";
          runtimeInputs = with pkgs; [
            nvchecker
            nvfetcher
            git
            prefetch-yarn-deps
          ];
          text = ''
            nvfetcher -o pkgs/_sources "$@"
            nvchecker -c nvchecker.toml
          '';
        };

        meta.description = ''
          Update pkgs/_sources
        '';
      };
    };
}
