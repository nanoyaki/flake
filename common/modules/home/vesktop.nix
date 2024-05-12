{
  config,
  pkgs,
  ...
}: {
  home.file.".config/vesktop/" = {
    source = ./vesktop;
    recursive = true;
  };
}
