{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    unrar
    unzip
    p7zip

    ncdu
  ];
}
