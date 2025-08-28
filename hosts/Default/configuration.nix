{
  pkgs,
  videoDriver,
  hostname,
  browser,
  browser2,
  editor,
  terminal,
  terminalFileManager,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/video/${videoDriver}.nix # Enable gpu drivers defined in flake.nix
    ../../modules/hardware/drives

    ../common.nix
    ../../modules/scripts

    ../../modules/desktop/hyprland # Enable hyprland window manager
    # ../../modules/desktop/i3-gaps # Enable i3 window manager

    #../../modules/programs/games
    ../../modules/programs/browser/${browser} # Set browser defined in flake.nix
    ../../modules/programs/browser/${browser2} # Set browser defined in flake.nix
    ../../modules/programs/terminal/${terminal} # Set terminal defined in flake.nix
    ../../modules/programs/editor/${editor} # Set editor defined in flake.nix
    ../../modules/programs/cli/${terminalFileManager} # Set file-manager defined in flake.nix
    ../../modules/programs/cli/starship
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    ../../modules/programs/shell/bash
    ../../modules/programs/shell/zsh
    # ../../modules/programs/media/discord
    # ../../modules/programs/media/spicetify
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/thunderbird
    # ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    # Power management solutions (can run together with different focus areas):
    ../../modules/programs/misc/tlp # Comprehensive system power management
    # ../../modules/programs/misc/cpufreq # Alternative CPU-focused power management
    ../../modules/programs/misc/thunar
    ../../modules/programs/misc/lact # GPU fan, clock and power configuration
    # ../../modules/programs/misc/nix-ld
    # ../../modules/programs/misc/virt-manager
  ];

  # Home-manager config
  # home-manager.sharedModules = [
  #   (_: {
  #     home.packages = with pkgs; [
  #       # pokego # Overlayed
  #       # krita
  #       #github-desktop
  #       # gimp
  #       # obsidian
  #     ];
  #   })
  # ];

  # Define system packages here
  environment.systemPackages = with pkgs; [
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = hostname; # Set hostname defined in flake.nix

  # Laptop-specific boot parameters
  boot.kernelParams = [
    "i915.enable_psr=1" # Panel Self Refresh for better battery life on Intel graphics
    "i915.enable_fbc=1" # Framebuffer compression for Intel graphics
    "i915.fastboot=1" # Skip unnecessary display modes
    "i915.enable_dc=2" # Display power management for Intel graphics
    "iwlwifi.power_save=1" # WiFi power saving
    # NVMe SSD power management for extended battery life
    "nvme_core.default_ps_max_latency_us=100000" # Power state transition time (100ms)
    "ahci.mobile_lpm_policy=3" # Aggressive link power management for SATA
  ];

  # Logind settings for laptop lid events
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
    extraConfig = ''
      HandlePowerKey=suspend
      HandlePowerKeyLongPress=poweroff
      IdleAction=suspend
      IdleActionSec=1800
    '';
  };


  # Enable firmware updates for device firmware
  services.fwupd.enable = true;

  # Network manager power saving
  networking.networkmanager.wifi.powersave = true;

  # Enable Blueman for Bluetooth management
  services.blueman.enable = true;

  # Add suspend-then-hibernate support
  systemd.sleep.extraConfig = ''
    SuspendMode=suspend-then-hibernate
    HibernateDelaySec=1800
  '';

  # Improve swap performance for laptops
  zramSwap.enable = true; # Compressed RAM swap
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 8 * 1024; # 8GB swap file for hibernation support
  }];

}
