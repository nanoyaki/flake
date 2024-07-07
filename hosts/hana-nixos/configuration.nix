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

  environment.systemPackages = with pkgs;
    [
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
    ]
    ++ [
      inputs.envision.packages."x86_64-linux".envision
    ];

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

  # Steam config taken from:
  # https://codeberg.org/Scrumplex/flake/src/commit/38473f45c933e3ca98f84d2043692bb062807492/nixosConfigurations/common/desktop/gaming.nix#L20-L35
  programs.steam = {
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

  programs.coolercontrol.enable = true;

  services.xserver.enable = true;
}
