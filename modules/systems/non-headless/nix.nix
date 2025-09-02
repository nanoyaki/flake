{
  inputs,
  ...
}:

let
  inherit (inputs) nixpkgs-wayland;
in

{
  nix.settings = {
    trusted-substituters = [
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  nixpkgs.overlays = [ nixpkgs-wayland.overlay ];
}
