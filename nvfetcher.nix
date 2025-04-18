{
  perSystem =
    { pkgs, ... }:
    {
      apps.nvfetcher = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "nvfetcher";
          runtimeInputs = with pkgs; [ nvfetcher ];
          text = ''
            nvfetcher -o pkgs/_sources --commit-changes
          '';
        };
      };
    };
}
