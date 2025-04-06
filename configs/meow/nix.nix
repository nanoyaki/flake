{ pkgs, inputs, ... }:

let
  inherit (inputs) nixpkgs-xr nixgl;
in

{
  nixpkgs.overlays = [ nixpkgs-xr.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.nixVersions.nix_2_27;
  nix.settings = {
    sandbox = true;
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };
}
