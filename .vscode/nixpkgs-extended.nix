{
  moduleExceptions ? [
    "flatpaks"
    "nixos-raspberrypi"
  ],
}:

let
  flake-compat = builtins.getFlake "github:edolstra/flake-compat";
  registry = builtins.fromJSON (
    builtins.unsafeDiscardStringContext (builtins.readFile /etc/nix/registry.json)
  );

  checkVersion = args: if registry.version > 2 then throw "Wron registry json version" else args;

  imported = builtins.listToAttrs (
    map (flake: {
      name = flake.from.id;
      value = (import flake-compat { src = flake.to.path; }).outputs or { };
    }) (builtins.filter (flake: flake.from.id != "nixpkgs") registry.flakes)
  );

  nixpkgs =
    (builtins.elemAt (builtins.filter (flake: flake.from.id == "nixpkgs") registry.flakes) 0).to.path;

  mapOutputs = output: map (name: output name imported.${name}) (builtins.attrNames imported);

  mapOutputsExcept =
    output: exceptions:
    map (name: output name imported.${name}) (
      builtins.filter (name: !(builtins.elem name exceptions)) (builtins.attrNames imported)
    );

  evalOr =
    toEval: args:

    let
      evaled = builtins.tryEval toEval;
    in

    if evaled.success then evaled.value else args;
in

checkVersion rec {
  pkgs = import nixpkgs {
    config.allowUnfree = true;

    overlays = mapOutputs (
      name: flake: evalOr (flake.overlays.${name} or flake.overlays.default or (_: _: { })) (_: _: { })
    );
  };

  inherit
    (import "${nixpkgs}/nixos/lib/eval-config.nix" {
      inherit pkgs;
      specialArgs.inputs = imported;
      baseModules =
        import "${nixpkgs}/nixos/modules/module-list.nix"
        ++ mapOutputsExcept (
          name: flake: evalOr (flake.nixosModules.${name} or flake.nixosModules.default or { }) { }
        ) moduleExceptions;

      modules = [ { } ];
    })
    options
    ;

  inputs = builtins.attrNames imported;
}
