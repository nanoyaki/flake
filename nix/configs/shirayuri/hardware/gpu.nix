{
  flake.nixosModules.shirayuri-gpu =
    { lib, pkgs, ... }:

    let
      overrideLactSettings =
        settings:

        lib.recursiveUpdate {
          version = 5;
          daemon = {
            log_level = "info";
            admin_group = "wheel";
            disable_clocks_cleanup = false;
          };
          apply_settings_timer = 5;
          gpus."1002:744C-1043:0506-0000:08:00.0" = {
            fan_control_enabled = true;
            fan_control_settings = {
              mode = "curve";
              static_speed = 0.5;
              temperature_key = "edge";
              interval_ms = 500;
              curve = {
                "55" = 0.31;
                "70" = 0.4;
                "80" = 0.55;
                "85" = 0.7;
                "90" = 0.99;
              };
              spindown_delay_ms = 5000;
              change_threshold = 2;
            };
            pmfw_options.zero_rpm = true;

            performance_level = "manual";
            # 4 = VR
            # 2 = POWER_SAVING
            power_profile_mode_index = 2;

            voltage_offset = -72;
            min_core_clock = 500;
            max_core_clock = 2895;
            max_memory_clock = 1250;
          };
          current_profile = null;
          auto_switch_profiles = false;
        } settings;
    in

    {
      boot.kernelModules = [ "amdgpu" ];

      hardware = {
        amdgpu.initrd.enable = true;
        amdgpu.overdrive = {
          enable = true;
          ppfeaturemask = "0xffffffff";
        };

        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };

      environment.variables.VDPAU_DRIVER = "radeonsi";
      environment.variables.AMD_VULKAN_ICD = "RADV";

      services.xserver.videoDrivers = [ "amdgpu" ];

      services.lact' = {
        enable = true;
        settings = lib.mkDefault (overrideLactSettings { });
      };

      specialisation.vr.configuration.services.lact'.settings = overrideLactSettings {
        gpus."1002:744C-1043:0506-0000:08:00.0" = {
          power_cap = 402;
          power_profile_mode_index = 4;
        };
      };

      systemd.tmpfiles.settings.rocm."/opt/rocm"."L+".argument =
        (pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages; [
            rocblas
            hipblas
            clr
          ];
        }).outPath;
    };
}
