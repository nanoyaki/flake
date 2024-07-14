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

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # Networking
  networking.hostName = "${username}-nixos";

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

  environment.systemPackages = with pkgs; [
    # Programming
    libgcc
    gcc

    # Games
    mangohud

    # VR
    pavucontrol
    index_camera_passthrough
    opencomposite-helper
    wlx-overlay-s
    lighthouse-steamvr
  ];

  services.pipewire = {
    extraConfig = {
      pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 2048;
          default.clock.min-quantum = 2048;
          default.clock.max-quantum = 2048;
        };
      };

      pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "2048/48000";
              pulse.default.req = "2048/48000";
              pulse.max.req = "2048/48000";
              pulse.min.quantum = "2048/48000";
              pulse.max.quantum = "2048/48000";
            };
          }
        ];

        stream.properties = {
          node.latency = "2048/48000";
        };
      };
    };
  };

  # Steam config taken from:
  # https://codeberg.org/Scrumplex/flake/src/commit/38473f45c933e3ca98f84d2043692bb062807492/nixosConfigurations/common/desktop/gaming.nix#L20-L35
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    extraPackages = with pkgs; [gamescope];
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      (proton-ge-bin.overrideAttrs (finalAttrs: _: {
        version = "GE-Proton9-9-rtsp11";
        src = pkgs.fetchzip {
          url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
          hash = "sha256-l/zt/Kv6g1ZrAzcxDNENByHfUp/fce3jOHVAORc5oy0=";
        };
      }))
    ];
  };

  programs.envision.enable = true;
  services.monado = {
    enable = true;
    defaultRuntime = false;
  };

  programs.coolercontrol.enable = true;

  services.xserver.enable = true;

  services.transmission = {
    enable = false;
    webHome = pkgs.flood-for-transmission;
  };
}
