{ inputs, ... }:

{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem =
    {
      lib,
      pkgs,
      self',
      config,
      ...
    }:

    let
      inherit (lib) mapAttrs' nameValuePair;
    in

    {
      pre-commit = {
        check.enable = true;
        settings.hooks = {
          statix.enable = true;
          flake-checker.enable = true;
          nixfmt-rfc-style.enable = true;
          deadnix.enable = true;
        };
      };

      devShells.default = config.pre-commit.devShell.overrideAttrs (prevAttrs: {
        buildInputs = (prevAttrs.buildInputs or [ ]) ++ (with pkgs; [ git ]);
      });

      checks = mapAttrs' (n: nameValuePair "devShell-${n}") self'.devShells;

      formatter = pkgs.nixfmt-tree;
    };

  systems = import inputs.systems;
}
