{
  self,
  lib,
  pkgs,
  config,
  username,
  ...
}:

{
  hm.sec = {
    "deploymentThelessone/private".path = "${config.hm.home.homeDirectory}/.ssh/deploymentThelessone";
    "deploymentYuri/private".path = "${config.hm.home.homeDirectory}/.ssh/deploymentYuri";
  };

  sec = {
    githubToken.owner = username;
    "keys.toml".owner = username;
  };

  networking.networkmanager.enable = true;

  nanoflake = {
    localization.language = [
      "en_GB"
      "de_DE"
      "ja_JP"
    ];
    audio.latency = lib.mkDefault 256;

    firefox.enablePolicies = true;
  };

  specialisation.osu.configuration.nanoflake.audio.latency = 32;

  environment.systemPackages = with pkgs; [
    imagemagick
    ffmpeg-full
    yt-dlp
    jq
    meow
    pyon
    nvtopPackages.amd
    wl-clipboard
    gimp
    feishin
    grayjay
    obs-studio
  ];

  programs.kde-pim.merkuro = true;

  virtualisation.waydroid.enable = true;

  services.printing.enable = true;

  # for deployment
  environment.etc."systems/yuri".source = self.nixosConfigurations.yuri.config.system.build.toplevel;

  hm.news.display = "show";
  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreib6be5oip6rht4vqnmldx5hzulr6irh55yarwbmxt2us2imfoiyd4@png";
    hash = "sha256-mQ8il+zU30EAxFAulUFkkXvYs9gubKCeQtaYRyJNXJ8=";
  };
}
