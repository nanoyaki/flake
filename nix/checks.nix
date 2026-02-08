{ inputs, ... }:

{
  perSystem =
    { lib, system, ... }:

    {
      checks =
        lib.mapAttrs'
          (name: cfg: {
            name = "home-configuration-${name}";
            value = cfg.activationPackage;
          })
          (
            lib.filterAttrs (
              _: cfg: cfg.pkgs.stdenv.hostPlatform.system == system
            ) inputs.self.homeConfigurations
          );
    };
}
