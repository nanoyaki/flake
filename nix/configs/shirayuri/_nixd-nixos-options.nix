{
  # A string containing the absolute path to the nixos configuration
  # for example: "/home/user/flake" or "/etc/nixos/configuration.nix"
  nixosConfig ? /etc/nixos/configuration.nix,
  # Whether the path to the nixos configuration is a flake
  isFlake ? false,
  # The hostname to use configuration options from in a flake
  hostname ? null,
}:

assert isFlake -> hostname != null;

let
  workspaceHasFlake = builtins.pathExists ./flake.nix;
  workspaceFlake = if workspaceHasFlake then builtins.getFlake (toString ./.) else null;
  systemFlake = if isFlake then builtins.getFlake (toString nixosConfig) else null;
  flake =
    if workspaceFlake != null && workspaceFlake ? nixosConfigurations.${hostname} then
      workspaceFlake
    else
      assert isFlake -> flake ? nixosConfigurations.${hostname};
      systemFlake;

  flakeOptions = flake.nixosConfigurations.${hostname}.options;
  defaultOptions =
    (import <nixpkgs/nixos> {
      configuration = /. + nixosConfig;
    }).options;
in

if workspaceHasFlake || isFlake then flakeOptions else defaultOptions
