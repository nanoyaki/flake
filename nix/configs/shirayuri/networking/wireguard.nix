{ withSystem, ... }:

{
  flake.nixosModules.shirayuri-wireguard =
    { pkgs, config, ... }:

    {
      sops.secrets = {
        wg0 = { };
        wg2 = { };
      };

      environment.systemPackages = [ pkgs.pangolin-cli ];

      networking.wg-quick.interfaces = {
        wg0 = {
          address = [
            "10.101.0.2/32"
            "fd10::2/128"
          ];
          privateKeyFile = config.sops.secrets.wg0.path;

          peers = [
            {
              publicKey = "kdBOsYomUk9YEFs+qSsKHnbaMAL6r57IlkJoNweRKj8=";
              endpoint = "hanakretzer.de:51820";
              allowedIPs = [
                "10.101.0.1/32"
                "fd10::1/128"
              ];
              persistentKeepalive = 25;
            }
          ];
        };

        wg2 = {
          address = [ "10.200.200.2/32" ];
          privateKeyFile = config.sops.secrets.wg2.path;

          peers = [
            {
              publicKey = "Pd934yDpHcc2pdv4eV2YBQYGgncW/yacNHtoNQsA5wM=";
              endpoint = "at02.theless.one:51821";
              allowedIPs = [ "10.200.200.1/32" ];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

  perSystem =
    { pkgs, ... }:

    {
      packages.pangolin-cli = pkgs.pangolin-cli.overrideAttrs (
        finalAttrs: prevAttrs: {
          version = "0.6.0";
          src = pkgs.fetchFromGitHub {
            owner = "fosrl";
            repo = "cli";
            tag = finalAttrs.version;
            hash = "sha256-9uQLCSH7LLl8I/LgsgTo6w808iwmH1FF0GYNn5xyVuc=";
          };

          ldflags = prevAttrs.ldflags or [ ] ++ [
            "-X github.com/fosrl/cli/internal/version.Version=${finalAttrs.version}"
          ];

          vendorHash = "sha256-eBrglhyqKy6pG9eF0yfJdCOLxeWys4atKAp9Jgtzdj8=";
        }
      );
    };

  flake.overlays.pangolin-cli =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) pangolin-cli;
      }
    );
}
