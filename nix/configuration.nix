{ ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

  # Determinate's installer runs its own Nix daemon, so nix-darwin must not manage Nix.
  nix.enable = false;

  # Leave the system shell startup files alone; only settings are managed here.
  programs.zsh.enable = false;
  programs.bash.enable = false;

  system.defaults.dock = {
    persistent-apps = [
      "/System/Applications/Messages.app"
      # /Applications/Safari.app is a symlink, which the Dock badges as an alias.
      "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
      "/Applications/Zed.app"
      "/System/Applications/System Settings.app"
    ];
    autohide = false;
  };

  system.defaults.WindowManager = {
    StandardHideWidgets = true;
    StageManagerHideWidgets = true;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    ShowPathbar = true;
  };
}
