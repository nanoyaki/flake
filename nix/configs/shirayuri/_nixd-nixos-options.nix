{
  # A string containing the absolute path to the nixos configuration
  # for example: "/home/user/flake" or "/etc/nixos/configuration.nix"
  nixosConfig ? /etc/nixos/configuration.nix,
  # Whether the path to the nixos configuration is a flake
  isFlake ? false,
  # The hostname to use configuration options from in a flake
  hostname ? null,
}:

let

  workspaceHasFlake = builtins.pathExists ./flake.nix;
  workspaceFlake = if workspaceHasFlake then builtins.getFlake (toString ./.) else null;
  systemFlake = if isFlake then builtins.getFlake (toString nixosConfig) else null;
  flake =
    if workspaceFlake != null && workspaceFlake ? nixosConfigurations then
      workspaceFlake
    else
      systemFlake;
  useHostname =
    if hostname == null then
      builtins.warn "Hostname not defined, falling back to the first one found" (
        builtins.head (builtins.attrNames flake.nixosConfigurations)
      )
    else
      hostname;

  flakeOptions =
    assert flake ? nixosConfigurations.${useHostname};
    flake.nixosConfigurations.${useHostname}.options;
  defaultOptions =
    (import <nixpkgs/nixos> {
      configuration = /. + nixosConfig;
    }).options;
in

if workspaceHasFlake || isFlake then flakeOptions else defaultOptions
