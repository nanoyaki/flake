{
  self,
  lib,
  lib',
  pkgs,
  config,
  ...
}:

{
  hm.sops.secrets = {
    deploymentThelessone.path = "${config.hm.home.homeDirectory}/.ssh/deploymentThelessone";
    deploymentYuri.path = "${config.hm.home.homeDirectory}/.ssh/deploymentYuri";
  };

  networking.networkmanager.enable = true;

  config' = {
    localization.language = [
      "en_GB"
      "de_DE"
      "ja_JP"
    ];
    audio.latency = lib.mkDefault 256;

    firefox.enable = true;
    mpv.enable = true;
    yubikey = {
      enable = true;
      yuri.enable = true;
    };
    steam.enable = true;
    theming.enable = true;
    monado.enable = true;
    flatpak.enable = true;
    ssh.defaultId = "${config.hm.home.homeDirectory}/.ssh/shirayuri-primary";
    keyboard.fcitx5.enable = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  specialisation.osu.configuration.config'.audio.latency = 32;

  environment.systemPackages =
    (with pkgs; [
      wl-clipboard
      gimp3-with-plugins
      feishin
      grayjay
      obs-studio
      nixd
      nixfmt-rfc-style
      signal-desktop
      nur.repos.ataraxiasjel.waydroid-script
      thunderbird-latest-bin
    ])
    ++ lib'.mapLazyCliApps (
      with pkgs;
      [
        imagemagick
        ffmpeg-full
        yt-dlp
        jq
        meow
        pyon
        nvtopPackages.amd
      ]
    );

  programs.kde-pim.merkuro = true;

  virtualisation.waydroid.enable = true;

  services.printing.enable = true;

  # for deployment
  environment.etc."systems/yuri".source = self.nixosConfigurations.yuri.config.system.build.toplevel;

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreib6be5oip6rht4vqnmldx5hzulr6irh55yarwbmxt2us2imfoiyd4@png";
    hash = "sha256-mQ8il+zU30EAxFAulUFkkXvYs9gubKCeQtaYRyJNXJ8=";
  };
}
