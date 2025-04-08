{
  lib,
  pkgs,
  inputs,
  self,
  config,
  ...
}:

let
  inherit (inputs) nixpkgs-xr nixgl;
  inherit (config.lib) nixGL;
in

{
  _module.args.lib'' = {
    nixGlOverlay =
      packages: _: prev:
      lib.mapAttrs (_: pkg: nixGL.wrap pkg) (
        lib.attrsets.filterAttrs (name: _: lib.lists.elem name packages) prev
      );
  };

  nixpkgs.overlays = [
    self.overlays.default
    nixpkgs-xr.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.nix_2_27;

    settings = {
      sandbox = true;
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  nixGL = {
    inherit (nixgl) packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };
}
