{ pkgs, ... }: {
  home-manager.sharedModules = [
    (_: {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
      };
    })
  ];
}
