{ config, ... }:
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
      # /Applications/Safari.app is a symlink, which the Dock badges as an alias.
      "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
      "/Applications/Zed.app"
      "/Applications/Ghostty.app"
    ];
    # No folders (such as Downloads) beside the Bin.
    persistent-others = [ ];
    autohide = false;
  };

  system.defaults.WindowManager = {
    StandardHideWidgets = true;
    StageManagerHideWidgets = true;
  };

  # Hiding still shows widgets when the desktop is revealed, so also empty the widget list.
  # It has no nix-darwin option and lives in Notification Centre's own settings file.
  system.defaults.CustomUserPreferences."/Users/${config.system.primaryUser}/Library/Containers/com.apple.notificationcenterui/Data/Library/Preferences/com.apple.notificationcenterui".widgets = {
    vers = 1;
    instances = [ ];
  };

  # The system-wide switch and the menu bar clock's own one.
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;
  system.defaults.menuExtraClock.Show24Hour = true;

  # The menu bar clock and the widgets only pick up new settings when their processes restart.
  system.activationScripts.postActivation.text = "killall ControlCenter NotificationCenter 2>/dev/null || true";

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    ShowPathbar = true;
  };
}
