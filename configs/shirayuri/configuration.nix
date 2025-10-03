{
  self,
  pkgs,
  inputs',
  config,
  ...
}:

let
  mapLazyCliApps =
    pkgs: map (pkg: inputs'.lazy-apps.packages.lazy-app.override { inherit pkg; }) pkgs;
in

{
  hm.sops = {
    secrets = {
      deploymentThelessone.path = ".ssh/deploymentThelessone";
      deploymentYuri.path = ".ssh/deploymentYuri";
    };
    defaultSopsFile = ./secrets/user-hana.yaml;
    inherit (config.sops) age;
  };

  networking.networkmanager.enable = true;

  config' = {
    mpv.enable = true;
    yubikey = {
      enable = true;
      yuri.enable = true;
    };
    steam.enable = true;
    theming.enable = true;
    monado.enable = true;
    flatpak.enable = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  specialisation.osu.configuration.nanoSystem.audio.latency = 32;

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
    ++ mapLazyCliApps (
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
  environment.etc = {
    "systems/yuri".source = self.nixosConfigurations.yuri.config.system.build.toplevel;
    "systems/yamayuri".source = self.nixosConfigurations.yamayuri.config.system.build.toplevel;
  };

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreiarzaifqcdw4mugzplv3t6qxp7kydjglgsy65dz3g4afyjlviemqy@png";
    hash = "sha256-VyyCflVNdt5k90vXkHxlQ9TvNjxk8NmZMxb45UMpCgA=";
  };
}
