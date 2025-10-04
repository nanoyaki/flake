{ pkgs, ... }:

let
  lactSettings = {
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
      power_profile_mode_index = 4; # VR
      voltage_offset = -72;
      min_core_clock = 500;
      max_core_clock = 2895;
      max_memory_clock = 1250;
    };
    current_profile = null;
    auto_switch_profiles = false;
  };

  lactConfig = pkgs.callPackage (
    {
      runCommand,
      remarshal_0_17,
      yq-go,
    }:
    runCommand "config.yaml"
      {
        nativeBuildInputs = [
          remarshal_0_17
          yq-go
        ];
        value = builtins.toJSON lactSettings;
        passAsFile = [ "value" ];
        preferLocalBuild = true;
      }
      ''
        json2yaml "$valuePath" raw.yaml
        yq -o=yaml '.gpus[].fan_control_settings.curve |= with_entries(.key |= tonumber)' raw.yaml > "$out"
      ''
  ) { };
in

{
  boot.kernelModules = [ "amdgpu" ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      overdrive = {
        enable = true;
        ppfeaturemask = "0xffffffff";
      };
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment.variables = {
    VDPAU_DRIVER = "radeonsi";
    AMD_VULKAN_ICD = "RADV";
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.systemPackages = [ pkgs.lact ];
  systemd.packages = [ pkgs.lact ];

  environment.etc."lact/config.yaml".source = lactConfig;

  systemd.services.lactd = {
    description = "LACT GPU Control Daemon";
    wantedBy = [ "multi-user.target" ];

    restartTriggers = [ lactConfig ];
  };

  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];
}
