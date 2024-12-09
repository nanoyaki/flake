{ inputs, ... }:

let
  inherit (inputs) aagl;
in

{
  imports = [ aagl.nixosModules.default ];
  nix.settings = aagl.nixConfig; # Cachix

  programs = {
    anime-game-launcher.enable = true;
    honkers-railway-launcher.enable = true;
    sleepy-launcher.enable = true;
  };
}
