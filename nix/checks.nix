{ inputs, ... }:

{
  perSystem =
    {
      lib,
      pkgs,
      system,
      config,
      ...
    }:

    {
      checks =
        (lib.mapAttrs'
          (name: cfg: {
            name = "home-configuration-${name}";
            value = cfg.activationPackage;
          })
          (
            lib.filterAttrs (
              _: cfg: cfg.pkgs.stdenv.hostPlatform.system == system
            ) inputs.self.homeConfigurations
          )
        )
        # NixOS configurations
        // (lib.mapAttrs'
          (name: cfg: {
            name = "nixos-configuration-${name}";
            value = cfg.config.system.build.toplevel;
          })
          (
            lib.filterAttrs (
              _: cfg: cfg.config.nixpkgs.hostPlatform.system == system
            ) inputs.self.nixosConfigurations
          )
        )
        # Packages
        // (lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
          lib.filterAttrs (
            _: pkg: !(pkg.meta.broken or false) && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg
          ) config.packages
        ));
    };
}
