{
  services.immich.mediaLocation = "/mnt/nvme-raid-1/var/lib/immich";

  config'.immich = {
    enable = true;
    homepage = {
      category = "Medien";
      description = "Foto backup software";
    };
  };
}
