# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.aagl.nixosModules.default

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    #inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # Networking
  networking.hostName = "${username}-nixos";

  # VR
  # TODO: put this in some module
  # services.monado = {
  #   package = pkgs.monado;
  #   enable = true;
  #   defaultRuntime = true;
  # };

  # Gnome:
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      seahorse # password something
    ]);
  services.xserver.desktopManager.xterm.enable = false;
  services.gnome.games.enable = false;
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  # VR Patch
  boot.kernelPatches = [
    {
      name = "cap_sys_nice_begone";
      patch = builtins.fetchurl {
        url = "https://codeberg.org/Scrumplex/flake/raw/commit/3ec4940bb61812d3f9b4341646e8042f83ae1350/pkgs/cap_sys_nice_begone.patch";
        sha256 = "07a1e8cb6f9bcf68da3a2654c41911d29bcef98d03fb6da25f92595007594679";
      };
    }
  ];

  environment.systemPackages = with pkgs;
    [
      # Programming
      libgcc
      gcc
      nodejs_22
      rustup
      pkg-config
      gnumake

      # Games
      mangohud

      # Image manipulation
      imagemagick
      gimp

      # VR
      unityhub
      vrc-get
      pavucontrol
      index_camera_passthrough
      opencomposite-helper
      wlx-overlay-s
      lighthouse-steamvr

      # OS
      usbutils

      # Files
      gnome.file-roller
      unrar
      unzip
      p7zip

      # Gnome Extensions:
      gnomeExtensions.appindicator
      gnomeExtensions.zen
      gnomeExtensions.window-is-ready-remover
    ]
    ++ [
      inputs.envision.packages."x86_64-linux".envision
    ];

  environment.variables = {
    PKG_CONFIG_PATH = "/run/current-system/sw/bin/openssl";
  };

  services.pipewire = {
    extraConfig = {
      pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 512;
          default.clock.min-quantum = 512;
          default.clock.max-quantum = 512;
        };
      };

      pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "512/48000";
              pulse.default.req = "512/48000";
              pulse.max.req = "512/48000";
              pulse.min.quantum = "512/48000";
              pulse.max.quantum = "512/48000";
            };
          }
        ];

        stream.properties = {
          node.latency = "512/48000";
          resample.quality = 1;
        };
      };
    };
  };

  nix.settings = inputs.aagl.nixConfig; # Set up Cachix

  # Gaming
  programs = {
    anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
    honkers-railway-launcher.enable = true;

    # Steam config taken from:
    # https://codeberg.org/Scrumplex/flake/src/commit/38473f45c933e3ca98f84d2043692bb062807492/nixosConfigurations/common/desktop/gaming.nix#L20-L35
    steam = {
      extraPackages = with pkgs; [gamescope];
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
        (proton-ge-bin.overrideAttrs (finalAttrs: _: {
          version = "GE-Proton9-4-rtsp7";
          src = pkgs.fetchzip {
            url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
            hash = "sha256-l/zt/Kv6g1ZrAzcxDNENByHfUp/fce3jOHVAORc5oy0=";
          };
        }))
      ];
    };

    gamemode = {
      enable = true;
      settings = {
        custom = {
          start = "qdbus org.kde.KWin /Compositor suspend";
          stop = "qdbus org.kde.KWin /Compositor resume";
        };
      };
    };

    coolercontrol.enable = true;
  };

  services.xserver.enable = true;

  virtualisation.virtualbox.host.enable = true;
}
