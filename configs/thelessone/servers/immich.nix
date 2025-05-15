{
  services.immich.accelerationDevices = [ "/dev/dri/renderD128" ];

  services.caddy-easify.reverseProxies."immich.theless.one".serverAliases = [
    "immich.nanoyaki.space"
  ];
}
