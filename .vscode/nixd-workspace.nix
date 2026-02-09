{
  path ? (toString ./..),
}:

let
  flake = builtins.getFlake path;

  inherit (flake.inputs) nixpkgs;
  inherit (nixpkgs) lib;
in

{
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    overlays =
      lib.flatten (
        map (input: builtins.attrValues input.overlays) (
          builtins.filter (input: input ? overlays) (builtins.attrValues flake.inputs)
        )
      )
      ++ (if flake ? overlays then builtins.attrValues flake.overlays else [ ]);
  };

  options = lib.foldl (acc: opts: lib.recursiveUpdate acc opts.options) { } (
    builtins.attrValues flake.nixosConfigurations
  );

  homeOptions = lib.foldl (acc: opts: lib.recursiveUpdate acc opts.options) { } (
    builtins.attrValues flake.homeConfigurations
  );
}
