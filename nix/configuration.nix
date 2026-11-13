{ ... }:
let
  user = builtins.getEnv "DOTFILES_USER";
in
{
  # User-level settings are written for this user. The chezmoi script passes it in.
  system.primaryUser =
    if user == "" then throw "DOTFILES_USER is not set: run `chezmoi apply` rather than darwin-rebuild." else user;

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

  # The system-wide switch and the menu bar clock's own one.
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;
  system.defaults.menuExtraClock.Show24Hour = true;

  # The menu bar clock only picks up a new setting when its process restarts.
  system.activationScripts.postActivation.text = "killall ControlCenter 2>/dev/null || true";

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    ShowPathbar = true;
  };
}
