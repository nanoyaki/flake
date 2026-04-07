{
  # A string containing the absolute path to the home configuration
  homeConfig,
  # A string of the absolute path to the nixos config.
  # Required if pathInNixosConfig is set
  nixosConfig ? null,
  # The path to the user's home configuration in the nixos configuration
  # for example: [ "home-manager" "users" "alice" ]
  pathInNixosConfig ? [ ],
  # Whether the path to the home configuration is a flake
  isFlake ? false,
  # The username/configuration key to look for in flakes
  # of which to use the options from
  username ? null,
}:

assert pathInNixosConfig != [ ] -> nixosConfig != null;
assert isFlake -> username != null;

let
  workspaceHasFlake = builtins.pathExists ./flake.nix;
  workspaceFlake = if workspaceHasFlake then builtins.getFlake (toString ./.) else null;
  homeFlake = if isFlake then builtins.getFlake (toString homeConfig) else null;
  flake =
    if workspaceFlake != null && workspaceFlake ? homeConfigurations.${username} then
      workspaceFlake
    else
      assert isFlake -> homeFlake ? homeConfigurations.${username};
      homeFlake;

  flakeOptions = flake.homeConfigurations.${username}.options;
  defaultOptions =
    if pathInNixosConfig == [ ] then
      fallbackOptions
    else
      (builtins.foldl' (acc: attr: acc.${attr})
        (import <nixpkgs/nixos> {
          src = /. + nixosConfig;
        }).config
        pathInNixosConfig
      ).options;
  fallbackOptions =
    (import <home-manager/modules> {
      configuration = /. + homeConfig;
      pkgs = import <nixpkgs> { };
    }).options;
in

if workspaceHasFlake || isFlake then flakeOptions else defaultOptions
