{
  self,
  inputs,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    self.overlays.default
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
      persistent = true;
    };

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  environment.variables.FLAKE_DIR = "$HOME/flake";

  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    nixd
  ];
}
