{
  flake.nixosModules.kanokoyuri-tailscale =
    { config, ... }:

    {
      sops.secrets.tailscale = { };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "server";
        authKeyFile = config.sops.secrets.tailscale.path;
        extraUpFlags = [
          "--login-server"
          "https://headscale.nanoyaki.space"
        ];
      };
    };
}
