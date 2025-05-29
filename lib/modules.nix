{
  lib,
  lib',
}:

let
  inherit (lib) mkIf foldl';
  inherit (lib.attrsets)
    genAttrs
    mapAttrs
    recursiveUpdate
    listToAttrs
    nameValuePair
    ;
  inherit (lib.trivial) isFunction;
  inherit (lib'.options)
    mkEither
    mkFunctionTo
    mkTrueOption
    mkDefault
    mkAttrsOption
    ;

  evalOrAttrs = actual: arguments: if isFunction actual then (actual arguments) else actual;
in

{
  modules = {
    /**
      Creates a Module attribute set. mkModule accepts an attribute set with the following keys:

      # Inputs

      Structured attribute set
      : Attribute set containing some or all of the following attributes.

        `name`
        : The name of the module.

        `options`
        : An attribute set of module options or
        : a function that accepts an attribute set with the following keys:

        # Inputs

        Structured attribute set
        : Attribute set containing any of the following attributes.

          `cfg'`
          : An attribute set of the dependencies mapped to their configurations

        `config`
        : An attribute set containing the module configuration or
        : a function that accepts an attribute set with the following keys:

        # Inputs

        Structured attribute set
        : Attribute set containing any of the following attributes.

          `cfg`
          : A shorthand for the module's configuration.

          `cfg'`
          : An attribute set of the dependencies mapped to their configurations.

          `helpers`
          : Helper functions defined in this module.

          `helpers'`
          : An attribute set of the dependencies mapped to their helper functions.

        `dependencies`
        : Modules exposing options and helper functions which this module requires.

        `sharedOptions`
        : Options exposed to dependents.

        `helpers`
        : Module-specific helper functions.

        `imports`
        : A list of other modules.
        : Same as in a default module.

      # Examples
      :::{.example}
      ## `lib'.modules.mkModule` usage example

      ```nix
      mkModule {
        name = "myService";
        options = { ... };
        config = { cfg, ... }: { ... };
      } // => { options.services'.myService = { ... }; config = { ... }; }
      ```

      :::
    */
    mkModule =
      {
        name,
        options ? { },
        config ? { },
        dependencies ? [ ],
        sharedOptions ? { },
        helpers ? { },
        imports ? [ ],
        specialArgs ? [ ],
      }:

      let
        config' = config;
      in

      moduleArgs@{
        config,
        pkgs,
        ...
      }:

      let
        cfg = config.services'.${name};
        cfg' = genAttrs dependencies (dep: config.services'.${dep});

        externalOptions =
          if dependencies != [ ] then
            foldl' (
              acc: dep: acc // (evalOrAttrs config.services'.${dep}._shared { inherit name; })
            ) { } dependencies
          else
            { };

        extraArgs = listToAttrs (map (arg: nameValuePair arg moduleArgs.${arg}) specialArgs);
      in

      {
        options.services'.${name} =
          {
            enable = mkTrueOption;
            _helpers = mkDefault helpers (mkEither mkAttrsOption (mkFunctionTo mkAttrsOption));
            _shared = mkDefault sharedOptions (mkEither mkAttrsOption (mkFunctionTo mkAttrsOption));
          }
          // recursiveUpdate externalOptions (
            evalOrAttrs options ({ inherit config cfg' pkgs; } // extraArgs)
          );

        inherit imports;

        config = mkIf cfg.enable (
          evalOrAttrs config' (
            {
              inherit
                config
                cfg
                cfg'
                pkgs
                ;
              helpers = evalOrAttrs helpers { inherit cfg; };
              helpers' = mapAttrs (_: cfg: evalOrAttrs cfg._helpers { inherit cfg; }) cfg';
            }
            // extraArgs
          )
        );
      };
  };
}
