{
  flake.nixosModules.kuroyuri-power = {
    services.power-profiles-daemon.enable = false;
    services.tlp.enable = true;
    services.tlp.pd.enable = true;

    services.tlp.settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      CPU_BOOST_ON_SAV = 0;
      CPU_DRIVER_OPMODE_ON_AC = "guided";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MAX_PERF_ON_BAT = 40;
      CPU_MAX_PERF_ON_SAV = 20;
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MIN_PERF_ON_SAV = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      DEVICES_TO_DISABLE_ON_BAT = "bluetooth wifi";
      DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
      DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "bluetooth";
      DEVICES_TO_ENABLE_ON_AC = "bluetooth wifi";
      DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth wifi";
      PCIE_ASPM_ON_BAT = "powersave";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      START_CHARGE_THRESH_BAT0 = 80;
      TLP_DEFAULT_MODE = "BAL";
      USB_AUTOSUSPEND = 1;
    };

    specialisation.powersave.configuration.services.tlp.settings = {
      USB_DENYLIST = "0bda:c123 5986:2160"; # BT, Camera
      USB_EXCLUDE_AUDIO = 0;
    };
  };
}
