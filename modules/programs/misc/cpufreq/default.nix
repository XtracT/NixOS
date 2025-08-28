{ ... }: {
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "schedutil";  # was "performance"
        turbo = "auto";
      };
      battery = {
        governor = "powersave";  # conservative power saving governor
        scaling_max_freq = 3600000; # ~75% of max 4800MHz (3.6GHz) for i7-8665U
        turbo = "never";
      };
    };
  };

  # Disable conflicting power management services
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = false;
}
