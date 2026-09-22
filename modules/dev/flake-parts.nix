{ inputs, ... }:

{
  imports = with inputs; [
    flake-file.flakeModules.auto-follow
    flake-file.flakeModules.dendritic
    flake-parts.flakeModules.modules
  ];

  flake-file.inputs = {
    # Using channels.nixos.org for higher availability than GitHub
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
    systems.flake = false;

    flake-file.url = "github:denful/flake-file";
    import-tree.url = "github:denful/import-tree";
  };

  systems = import inputs.systems;
  debug = true;
}
