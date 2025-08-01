{
  description = "A simple flake for an atomic system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:Sly-Harvey/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
    thunderbird-catppuccin = {
      url = "github:catppuccin/thunderbird";
      flake = false;
    };
    zen-browser = {
      url = "github:maximoffua/zen-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    settings = {
      # User configuration
      username = "xtract"; # automatically set with install.sh and live-install.sh
      editor = "vscode"; # nixvim, vscode, nvchad, neovim, emacs (WIP)
      browser = "firefox"; # firefox, floorp, zen
      terminal = "kitty"; # kitty, alacritty, wezterm
      terminalFileManager = "yazi"; # yazi or lf
      sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
      wallpaper = "kurzgesagt"; # see modules/themes/wallpapers

      # System configuration
      videoDriver = "intel"; # CHOOSE YOUR GPU DRIVERS (nvidia or amdgpu or intel) THIS IS IMPORTANT
      hostname = "NixOS"; # CHOOSE A HOSTNAME HERE
      locale = "en_US.UTF-8"; # CHOOSE YOUR LOCALE
      timezone = "Europe/Berlin"; # CHOOSE YOUR TIMEZONE
      kbdLayout = "se"; # CHOOSE YOUR KEYBOARD LAYOUT00
      kbdVariant = ""; # CHOOSE YOUR KEYBOARD VARIANT (Can leave empty)
      consoleKeymap = "sv-latin1"; # CHOOSE YOUR CONSOLE KEYMAP (Affects the tty?)
    };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    templates = import ./dev-shells;
    overlays = import ./overlays {inherit inputs settings;};
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    nixosConfigurations = {
      Default = nixpkgs.lib.nixosSystem {
        system = forAllSystems (system: system);
        specialArgs = {inherit self inputs outputs;} // settings;
        modules = [./hosts/Default/configuration.nix];
      };
    };
  };
}
