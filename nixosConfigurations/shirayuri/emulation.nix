{
  pkgs,
  ...
}:

{
  environment.systemPackages =
    (with pkgs; [
      dolphin-emu
    ])
    ++ [
      # config.nur.repos.aprilthepink.suyu-mainline
    ];
}
