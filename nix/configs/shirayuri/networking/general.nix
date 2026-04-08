{
  flake.nixosModules.shirayuri-networking =
    { config, ... }:

    {
      networking = {
        hostId = "57ced6bb";
        hostName = "shirayuri";

        useDHCP = false;
        networkmanager.enable = true;
      };

      sops.secrets.cache-thelessone = { };
      sops.templates."cache.netrc".content = ''
        machine binarycache.theless.one
        password ${config.sops.placeholder.cache-thelessone}
      '';

      nix.settings.netrc-file = config.sops.templates."cache.netrc".path;
    };
}
