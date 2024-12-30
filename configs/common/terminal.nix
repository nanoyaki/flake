{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (inputs) ghostty;
  inherit (lib) mkEnableOption mkIf;

  cfg = config.modules.terminal;
in

{
  options.modules.terminal = {
    enableGhostty = mkEnableOption "ghostty";
    enableKitty = mkEnableOption "kitty";
  };

  config =
    {
      hm.programs = {
        kitty = {
          enable = cfg.enableKitty;

          font = {
            package = pkgs.cascadia-code;
            name = "Cascadia Mono";
            size = 13;
          };
        };

        alacritty = {
          enable = true;

          settings.terminal.shell = lib.mkIf config.hm.programs.zellij.enable {
            program = "zellij";
            args = [
              "attach"
              "default"
              "-c"
            ];
          };
        };
      };
    }
    // mkIf cfg.enableGhostty {
      nixpkgs.overlays = [ ghostty.overlays.default ];

      nix.settings = {
        trusted-substituters = [ "https://ghostty.cachix.org" ];
        trusted-public-keys = [ "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns=" ];
      };

      environment.systemPackages = [ pkgs.ghostty ];
    };
}
