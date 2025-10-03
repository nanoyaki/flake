{ pkgs, config, ... }:

{
  sops.secrets.tailscale = { };

  config' = {
    mpv.enable = true;
    yubikey = {
      enable = true;
      yuri.enable = true;
    };
    theming.enable = true;
  };

  environment.systemPackages = with pkgs; [
    meow
    pyon
    nvtopPackages.amd
    wl-clipboard
    gimp3-with-plugins
    feishin
    # grayjay
    prismlauncher
    melonDS
  ];

  programs.thunderbird.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.sops.secrets.tailscale.path;
  };

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreib6be5oip6rht4vqnmldx5hzulr6irh55yarwbmxt2us2imfoiyd4@png";
    hash = "sha256-mQ8il+zU30EAxFAulUFkkXvYs9gubKCeQtaYRyJNXJ8=";
  };
}
