{ ... }: {
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling governors for Intel i7-8665U (Coffee Lake)
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Intel Energy Performance Policy
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power"; # Aggressive power saving
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance"; # Balanced performance on AC

      # Performance limits for Intel i7-8665U (4.8GHz max)
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100; # Full performance on AC
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 70; # 3.36GHz max on battery (~70% of 4.8GHz)

      # Battery protection - good charge thresholds
      START_CHARGE_THRESH_BAT0 = 82;
      STOP_CHARGE_THRESH_BAT0 = 95;
      START_CHARGE_THRESH_BAT1 = 82;
      STOP_CHARGE_THRESH_BAT1 = 95;

      # Laptop power optimizations
      CPU_BOOST_ON_AC = 1; # Enable turbo boost on AC
      CPU_BOOST_ON_BAT = 0; # Disable turbo boost on battery

      # WiFi power management (Intel AX210/AX200 typically)
      WIFI_PWR_ON_AC = 1; # Power saving disable on AC
      WIFI_PWR_ON_BAT = 5; # Aggressive power saving on battery

      # USB power management
      USB_DENYLIST = "usbhid.uhci-hcd:uhci_hcd"; # Maintain USB functionality
      USB_BLACKLIST_BTUSB = 0; # Keep Bluetooth working
      USB_BLACKLIST_PHONE = 0; # Keep USB tethering
    };
  };

  # Disable conflicting power management (auto-cpufreq handled above)
  services.power-profiles-daemon.enable = false;
}
