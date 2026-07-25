{ inputs, ... }:

{
  imports = with inputs; [
    treefmt-nix.flakeModule
    pedantix.flakeModules.default
  ];

  perSystem =
    _:

    {
      treefmt.programs = {
        mdformat.enable = true;
        nixfmt.enable = true;
        pedantix.enable = true;

        pedantix.settings = {
          args = {
            blank-lines = 1;
            blank-lines-mode = "off";

            first = [
              # Flake module
              "self"
              "self'"
              "inputs"
              "inputs'"
              "withSystem"

              # NixOS module
              "lib"
              "pkgs"
              "options"
              "config"
              "modulesPath"
              "utils"

              # Package
              "stdenv"
              "stdenvNoCC"
              "runCommand"
              "rustPlatform"
              "buildPythonPackage"
              "buildComposerProject2"
              "applyPatches"
              "fetchurl"
              "fetchFromGitHub"
              "fetchFromGitLab"
              "just"
              "pkg-config"
              "cacert"
              "autoPatchelfHook"
              "libcosmicAppHook"
              "udevCheckHook"
            ];

            last = [
              "..."
              "<defaulted>"
            ];

            sort = true;
          };

          attrs = {
            blank-lines = 1;
            blank-lines-mode = "multiline";

            first = [
              # Top-level NixOS module
              "imports"
              "options"
              "config"

              # In the module
              "nix"
              "nixpkgs"
              "hardware"
              "sops"
              "boot"
              "environment"
              "users"
              "services"
              "programs"

              # Inside those
              "enable"
              "openFirewall"
              "package"
            ];

            flatten = true;

            last = [
              "..."
              # Settings in a module can be very lengthy
              "settings"
              # Top-level
              "home"
              "system"
              "systemd"
              "specialisation"
            ];

            sort = true;
          };

          formatter = "nixfmt";

          inherits = {
            blank-lines = 0;
            blank-lines-mode = "all";

            first = [
              # NixOS modules
              "types"
              "mkOption"
              "mkEnableOption"
              "mkIf"
              "mkMerge"
              "mkDefault"
              "mkForce"
            ];

            flatten = true;

            last = [
              "..."
            ];

            sort = true;
          };

          lets = {
            blank-lines = 1;
            blank-lines-mode = "multiline";

            first = [
              "cfg"
              "format"
              "configFile"
            ];

            flatten = true;

            last = [
              "..."
              "<defaulted>"
            ];

            sort = true;
          };

          lists = {
            blank-lines = 1;
            blank-lines-mode = "all";
            first = [ "inputs" ];

            last = [
              "..."
              "<defaulted>"
            ];

            sort = false;
          };

          overrides =
            let
              fetcher.attrs.first = [
                # Fetchers
                "url"
                "owner"
                "repo"
                "name"
                "rev"
                "tag"
                "hash"
                "sha256"
                "fetchSubmodules"
              ];
              package = {
                args = {
                  first = [
                    "lib"
                    "stdenv"
                    "stdenvNoCC"
                    "runCommand"
                    "rustPlatform"
                    "buildPythonPackage"
                    "buildComposerProject2"
                    "applyPatches"
                    "fetchurl"
                    "fetchFromGitHub"
                    "fetchFromGitLab"
                    "just"
                    "pkg-config"
                    "cacert"
                    "autoPatchelfHook"
                    "libcosmicAppHook"
                    "udevCheckHook"
                  ];

                  last = [
                    "..."
                    "<defaulted>"
                  ];
                };

                attrs = {
                  first = [
                    # Package
                    "name"
                    "pname"
                    "version"
                    "src"
                    "cargoDeps"
                    "cargoHash"
                    "vendorHash"
                    "pnpmDeps"
                    "yarnDeps"
                    "npmDepsHash"
                    "outputs"
                    "__structuredAttrs"
                    "strictDeps"
                    "env"
                    "patches"
                    "postPatch"
                    "nativeBuildInputs"
                    "buildInputs"
                    "propagatedBuildInputs"
                    # Python stuff
                    "runtimeDependencies"
                    # symlinkJoin specific
                    "paths"
                    "configureFlags"
                    "cmakeFlakes"
                    "mesonFlags"
                    "buildFlags"
                    "preConfigure"
                    "postConfigure"
                    "preBuild"
                    "buildPhase"
                    "postBuild"
                    "preInstall"
                    "installPhase"
                    "postInstall"
                    "preFixup"
                    "postFixup"
                    "doCheck"
                    "checkFlags"
                    "nativeCheckInputs"
                    "checkInputs"
                    "preCheck"
                    "checkPhase"
                    "postCheck"
                    "doInstallCheck"
                    "nativeInstallCheckInputs"
                    "installCheckPhase"
                  ];

                  last = [
                    "..."
                    "outputHash"
                    "outputHashAlgo"
                    "passthru"
                    "meta"
                  ];
                };
              };
            in
            [
              # Fetchers
              {
                inherit (fetcher) attrs;
                path = "**.src";
              }
              {
                inherit (package) args;
                path = "**.legacyPackages.**";

                attrs = {
                  inherit (package.attrs) last;
                  first = package.attrs.first ++ fetcher.attrs.first;
                };
              }
              {
                inherit (package) args;
                path = "**.packages.*";

                attrs = {
                  inherit (package.attrs) last;
                  first = package.attrs.first ++ fetcher.attrs.first;
                };
              }
              # Meta
              {
                path = "**.meta";

                attrs.first = [
                  "description"
                  "longDescription"
                  "homepage"
                  "changelog"
                  "license"
                  "sourceProvenance"
                  "maintainers"
                  "platforms"
                  "badPlatforms"
                  "mainProgram"
                ];
              }
              # Passthru
              {
                path = "**.passthru";
                attrs.first = [ "updateScript" ];

                attrs.last = [
                  "..."
                  "finalPackage"
                ];
              }
              # Never sort these lists
              {
                path = "**.modules";
                lists.sort = false;
              }
              {
                path = "**.overlays";
                lists.sort = false;
              }
              {
                path = "**.imports";
                lists.sort = false;
              }
              # Pedantix overrides
              {
                path = "**.pedantix.settings.overrides";
                attrs.first = [ "path" ];
              }
              {
                path = "inputs";
                attrs.sort = false;
              }
              # Installed packages
              {
                path = "**.environment.systemPackages";
                lists.sort = true;
              }
              {
                path = "**.home.packages";
                lists.sort = true;
              }
              # Systemd service
              {
                path = "**.systemd.services.*";

                attrs.first = [
                  "enable"
                  "name"
                  "description"
                  "wantedBy"
                  "conflicts"
                  "requires"
                  "requisite"
                  "wants"
                  "upheldBy"
                  "upholds"
                  "partOf"
                  "before"
                  "after"
                  "path"
                  "environment"
                  "preStart"
                  "script"
                  "postStart"
                  "reload"
                  "preStop"
                  "postStop"
                ];

                attrs.last = [
                  "..."
                  "confinement"
                  "unitConfig"
                  "serviceConfig"
                  "onSuccess"
                  "onFailure"
                  "reloadIfChanged"
                  "reloadTriggers"
                  "restartIfChanged"
                  "restartTriggers"
                  "stopIfChanged"
                ];
              }
              {
                path = "**.systemd.services.confinement";

                attrs.first = [
                  "enable"
                  "mode"
                  "packages"
                ];
              }
              {
                path = "flake.nixosConfigurations.*";
                attrs.first = [ "system" ];
              }
              {
                path = "flake.homeConfigurations.*";
                attrs.first = [ "pkgs" ];
              }
            ];

          top-level-blank-lines = 1;
          top-level-blank-lines-mode = "off";
        };

        toml-sort.enable = true;
      };

      treefmt.projectRootFile = "LICENSE";
    };
}
