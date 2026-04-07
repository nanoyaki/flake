{
  # A string containing the absolute path to the nixos configuration
  # for example: "/home/user/flake" or "/etc/nixos/configuration.nix"
  nixosConfig ? /etc/nixos/configuration.nix,
  isFlake ? false,
}:

let
  workspaceHasFlake = builtins.pathExists ./flake.nix;
  workspaceFlake = if workspaceHasFlake then builtins.getFlake (toString ./.) else null;
  systemFlake = if isFlake then builtins.getFlake (toString nixosConfig) else null;
  flake =
    if workspaceFlake != null && workspaceFlake ? inputs.nixpkgs then
      workspaceFlake
    else
      assert isFlake -> systemFlake ? inputs.nixpkgs;
      systemFlake;

  nixpkgs = if flake != null then flake.inputs.nixpkgs else <nixpkgs>;
in

import nixpkgs {
  config.allowUnfree = true;
  overlays =
    builtins.concatLists (
      map (input: builtins.attrValues input.overlays) (
        builtins.filter (input: input ? overlays) (builtins.attrValues flake.inputs)
      )
    )
    ++ (if flake ? overlays then builtins.attrValues flake.overlays else [ ]);
}
