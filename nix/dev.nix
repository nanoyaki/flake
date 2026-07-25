{ inputs, ... }:

{
  imports = [ inputs.git-hooks-nix.flakeModule ];
  debug = true;

  perSystem =
    {
      config,
      lib,
      pkgs,
      self',
      ...
    }:

    let
      inherit (lib) mapAttrs' nameValuePair;
    in

    {
      checks = mapAttrs' (n: nameValuePair "devShell-${n}") self'.devShells;

      devShells.default = config.pre-commit.devShell.overrideAttrs (prevAttrs: {
        buildInputs = (prevAttrs.buildInputs or [ ]) ++ (with pkgs; [ git ]);
      });

      pre-commit = {
        check.enable = true;

        settings.hooks = {
          deadnix.enable = true;
          flake-checker.enable = true;
          nixfmt.enable = true;
          statix.enable = true;
        };
      };
    };

  systems = import inputs.systems;
}
