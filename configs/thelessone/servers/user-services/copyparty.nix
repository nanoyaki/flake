{ inputs, pkgs, ... }:

let
  inherit (inputs) copyparty;
in

{
  imports = [ copyparty.nixosModules.default ];
  nixpkgs.overlays = [ copyparty.overlays.default ];

  services.copyparty = {
    enable = true;
    package = pkgs.copyparty.override { inherit (pkgs) partftpy; };
    mkHashWrapper = true;
    volumes."/" = {
      path = "/mnt/raid/copyparty";
      access.r = "*";
    };
  };
}
