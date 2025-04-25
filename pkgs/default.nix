{ self, inputs, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        callPackageWith
        mapAttrs
        mapAttrsToList
        concatStrings
        ;

      inherit (builtins)
        removeAttrs
        readDir
        ;

      callPackage = callPackageWith (
        pkgs
        // {
          _sources = pkgs.callPackage ./_sources/generated.nix { };
        }
      );
    in
    {
      overlayAttrs = config.packages;

      packages = mapAttrs (name: _: callPackage (./. + "/${name}") { }) (
        removeAttrs (readDir ./.) [
          "_sources"
          "default.nix"
        ]
      );

      apps.buildAllx86Pkgs = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "buildAllx86Pkgs";
          runtimeInputs = with pkgs; [ nix-fast-build ];
          text = concatStrings (
            mapAttrsToList (name: _: ''
              echo "Building ${name}..."
              nix-fast-build -f "${self}#packages.x86_64-linux.${name}" "$@"

            '') self.packages.x86_64-linux
          );
        };
      };
    };
}
