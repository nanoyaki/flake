{
  services.immich = {
    enable = true;
    port = 2283;
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
