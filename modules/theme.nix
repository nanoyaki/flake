{ withSystem, config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.theme ];
  };

  modules.nixos.theme =
    { lib, config, ... }:

    let
      inherit (lib) mkOption types;
    in

    {
      options.environment.theme.wallpaper = mkOption {
        type = types.nullOr types.storePath;
        default = withSystem config.nixpkgs.hostPlatform ({ config, ... }: config.packages.wallpaper);
        defaultText = "withSystem config.nixpkgs.hostPlatform ({ config, ... }: config.packages.wallpaper)";
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.wallpaper = pkgs.fetchPixivIllust {
        id = 140824539;
        hash = "sha256-MjEEnE6t4B2zhGE1oDCpMGGQO9rI97eFnhH4Nz4P9X0=";
      };
    };
}
