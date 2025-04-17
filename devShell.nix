{
  transposition.lib = { };

  perSystem =
    {
      pkgs,
      inputs',
      config,
      ...
    }:
    {
      checks.pre-commit-check = inputs'.pre-commit-hooks.lib.run {
        src = ./.;
        hooks = {
          statix.enable = true;
          flake-checker.enable = true;

          nixfmt-rfc-style = {
            enable = true;
            excludes = [ "^pkgs/_sources.*" ];
          };

          deadnix = {
            enable = true;
            excludes = [ "^pkgs/_sources.*" ];
          };
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (config.checks.pre-commit-check) shellHook;
        buildInputs = config.checks.pre-commit-check.enabledPackages;
      };
    };
}
