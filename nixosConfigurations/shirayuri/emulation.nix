{
  pkgs,
  config,
  inputs',
  ...
}:

{
  environment.systemPackages =
    (with pkgs; [
      dolphin-emu
      cemu
    ])
    ++ [
      inputs'.prismlauncher.packages.prismlauncher
      config.nur.repos.aprilthepink.suyu-mainline
    ];
}
