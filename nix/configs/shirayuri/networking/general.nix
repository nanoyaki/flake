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

      nix.settings = {
        extra-trusted-public-keys = [ "global:7eCH4KGNBFCRbdj68YYwR053mXl2zJRCUkV2LKtitnk=" ];
        extra-trusted-substituters = [ "https://binarycache.theless.one/global" ];
        netrc-file = config.sops.templates."cache.netrc".path;
      };
    };
}
