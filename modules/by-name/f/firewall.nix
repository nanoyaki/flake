{ lib', ... }:

let
  inherit (lib'.options) mkNullOr mkPortOption mkTrueOption;
in

lib'.modules.mkModule {
  name = "firewall";

  sharedOptions = {
    port = mkNullOr mkPortOption;
    openFirewall = mkTrueOption;
  };

  helpers.defaultPort = cfg: default: if cfg.port != null then cfg.port else default;
}
