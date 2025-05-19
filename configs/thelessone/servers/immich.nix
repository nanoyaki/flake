{ lib, ... }:

{
  services.immich.accelerationDevices = [ "/dev/dri/renderD128" ];

  services.media-easify.services.immich.subdomain = "immich.vpn";

  services.headscale.settings.dns.extra_records = lib.singleton {
    name = "immich.vpn.theless.one";
    type = "A";
    value = "100.64.64.1";
  };
}
