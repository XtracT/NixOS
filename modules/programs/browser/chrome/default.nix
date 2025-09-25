{ pkgs, ... }:

{
  home-manager.sharedModules = [
    (_: {
      home.packages = with pkgs; [
        google-chrome
      ];
    })
  ];
}