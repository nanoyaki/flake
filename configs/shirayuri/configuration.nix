{
  lib,
  pkgs,
  inputs',
  config,
  prev,
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

  inherit (config.services.displayManager) defaultSession;
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

  specialisation.osu.configuration.nanoSystem.audio.latency = 32;

  environment.systemPackages =
    (with pkgs; [
      wl-clipboard
      gimp3-with-plugins
      grayjay
      obs-studio
      nixd
      nixfmt-rfc-style
      signal-desktop
      nur.repos.ataraxiasjel.waydroid-script
      thunderbird-latest-bin
      vesktop
      spotify
      libreoffice-qt6-fresh
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

  xdg.mime.defaultApplications."x-scheme-handler/spotify" = "spotify.desktop";

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

  hm.programs = lib.optionalAttrs config.services.desktopManager.cosmic.enable {
    cosmic-files.settings.favorites = [
      (EnumVariant "Path" "/mnt/os-shared")
      (EnumVariant "Path" "/mnt/copyparty")
    ];
  };

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

  i18n.extraLocales = [ "ja_JP.UTF-8/UTF-8" ];

  services.greetd.settings = lib.mkForce (
    if (defaultSession == "cosmic" || defaultSession == null) then
      prev.config.services.greetd.settings
    else
      prev.config.services.greetd.settings
      // {
        initial_session = {
          command = lib.getExe' pkgs.kdePackages.plasma-workspace "startplasma-wayland";
          inherit (config.services.displayManager.autoLogin) user;
        };
      }
  );

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };

  programs.droidcam.enable = true;
  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=0 width=1920 max_width=1920 height=1080 max_height=1080 format=YU12 exclusive_caps=1 card_label=Phone debug=1
  '';
}
