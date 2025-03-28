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
          nixfmt-rfc-style.enable = true;
          statix.enable = true;
          deadnix.enable = true;
          flake-checker.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (config.checks.pre-commit-check) shellHook;
        buildInputs = config.checks.pre-commit-check.enabledPackages;
      };
    };
}
