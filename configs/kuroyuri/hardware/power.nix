{
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.tlp.enable = true;
  services.tlp.settings = {
    TLP_DEFAULT_MODE = "BAL";

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_DRIVER_OPMODE_ON_AC = "guided";
    CPU_DRIVER_OPMODE_ON_BAT = "active";
    CPU_MIN_PERF_ON_AC = 0;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 40;
    CPU_MIN_PERF_ON_SAV = 0;
    CPU_MAX_PERF_ON_SAV = 20;
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 1;
    CPU_BOOST_ON_SAV = 0;

    RUNTIME_PM_ON_AC = "on";
    RUNTIME_PM_ON_BAT = "auto";
    PCIE_ASPM_ON_BAT = "powersave";

    START_CHARGE_THRESH_BAT0 = 80;

    USB_AUTOSUSPEND = 1;

    DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "bluetooth";
    DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth wifi";
    DEVICES_TO_ENABLE_ON_AC = "bluetooth wifi";
    DEVICES_TO_DISABLE_ON_BAT = "bluetooth wifi";
  };

  specialisation.powersave.configuration.services.tlp.settings = {
    USB_DENYLIST = "0bda:c123 5986:2160"; # BT, Camera
    USB_EXCLUDE_AUDIO = 0;
  };
}
