{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (lib) mkOption types;
  inherit (lib.modules) mkAliasOptionModule;
  inherit (inputs) sops-nix;

  cfg = config.nanoflake.sopsFile;

  sopsCfg = {
    defaultSopsFile = cfg;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.hm.xdg.configHome}/sops/age/keys.txt";
  };
in

{
  options.nanoflake.sopsFile = mkOption {
    type = types.pathInStore;
    default = ./. + "../../../${config.networking.hostName}/secrets.yaml";
    example = lib.literalExpression "./secrets.yaml";
    description = "The default sops file for the system";
  };

  imports = [
    sops-nix.nixosModules.sops
    (mkAliasOptionModule
      [ "sec" ]
      [
        "sops"
        "secrets"
      ]
    )
  ];

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        sops = prev.sops.overrideAttrs (oldAttrs: rec {
          version = "c78b0aae0ed04fbc411de3f286097a98cc5532b3";
          src = prev.fetchFromGitHub {
            owner = "getsops";
            repo = oldAttrs.pname;
            rev = version;
            hash = "sha256-TXnsdGh6838489RPtKg5xEHQ/uJhkRjHE1Jx+3Y3ib0=";
          };
          vendorHash = "sha256-gxOWCMkqwu3FMlo4KZFcCTfxLi7HILu5xPDJgnTEk6s=";
          doInstallCheck = false;
        });
      })
    ];

    sops = sopsCfg;

    home-manager.sharedModules = [
      sops-nix.homeManagerModules.sops
    ];
    hm.imports = [
      (mkAliasOptionModule
        [ "sec" ]
        [
          "sops"
          "secrets"
        ]
      )
    ];
    hm.sops = sopsCfg;

    environment.systemPackages = [ pkgs.sops ];
  };
}
