{
  config,
  pkgs,
  ...
}: {
  # dirty workaround since im dumb
  # home.file.".config/mongodb/" = {
  #   source = ../../common/modules/mongodb/configs;
  #   recursive = true;
  # };
}
