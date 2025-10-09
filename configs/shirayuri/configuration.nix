{
  # lib,
  pkgs,
  inputs',
  config,
  ...
}:

let
  mapLazyCliApps =
    pkgs: map (pkg: inputs'.lazy-apps.packages.lazy-app.override { inherit pkg; }) pkgs;

  Enum = config.hm.lib.cosmic.mkRON "enum";
  EnumVariant =
    variant: value:
    Enum {
      value = [ value ];
      inherit variant;
    };
in

{
  sops.secrets = {
    id_thelessone_deployment = {
      path = "${config.users.users.${config.nanoSystem.mainUserName}.home}/.ssh/id_thelessone_deployment";
      owner = config.nanoSystem.mainUserName;
      mode = "400";
    };

    id_yuri_deployment = {
      path = "${config.users.users.${config.nanoSystem.mainUserName}.home}/.ssh/id_yuri_deployment";
      owner = config.nanoSystem.mainUserName;
      mode = "400";
    };
  };

  networking.networkmanager.enable = true;

  services.desktopManager.cosmic.enable = true;

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
      vesktop
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

  # hm.wayland.desktopManager.cosmic.wallpapers = lib.mkForce [
  #   {
  #     output = "all";
  #     source = EnumVariant "Path" "/home/hana/owned-material/images/szcb911/2024-10-15.jpeg";
  #     filter_by_theme = true;
  #     rotation_frequency = 300;
  #     filter_method = Enum "Lanczos";
  #     scaling_mode = Enum "Zoom";
  #     sampling_method = Enum "Alphanumeric";
  #   }
  # ];

  hm.programs.cosmic-files.settings.favorites = [
    (EnumVariant "Path" "/mnt/os-shared")
    (EnumVariant "Path" "/mnt/copyparty")
  ];

  sops.secrets.copyparty-mount = { };

  services.copyparty-mount = {
    enable = true;
    server = "https://files.theless.one";
    copyparty.sopsPasswordPlaceholder = config.sops.placeholder.copyparty-mount;
    fsExtraOptions = [
      "uid=${toString config.users.users.${config.nanoSystem.mainUserName}.uid}"
      "gid=${toString config.users.groups.users.gid}"
    ];
  };

  users.users.${config.nanoSystem.mainUserName}.uid = 1000;

  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreiarzaifqcdw4mugzplv3t6qxp7kydjglgsy65dz3g4afyjlviemqy@png";
    hash = "sha256-VyyCflVNdt5k90vXkHxlQ9TvNjxk8NmZMxb45UMpCgA=";
  };
}
