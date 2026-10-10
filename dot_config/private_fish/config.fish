# Brew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

# Mise
if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate fish | source
end

if status is-interactive
    if command -q zoxide
        zoxide init fish | source
    end
end

abbr -a gs git status
abbr -a gp git push
abbr -a gl git pull
abbr -a gd git diff

alias ls "eza --group-directories-first --git"
alias ll "eza --group-directories-first --git -l"

# Hide fish's missing-newline indicator (black on black = invisible)
set -U fish_color_no_newline --background=black black
set -U hydro_symbol_prompt "›"
set -U hydro_color_prompt 808080
set -U hydro_fetch false
set -U hydro_color_pwd 808080
set -U hydro_color_git fab387
set -U hydro_symbol_git_dirty " ±"
set -U hydro_cmd_duration_threshold 9999999

# Hydro has no length limit; cap each long path segment and the branch (worktree names are long).
set -g hydro_max_segment 24
function fish_prompt --description "Hydro, truncated"
    set -l pat "([^/\e]{$hydro_max_segment})[^/\e]+"
    set -l pwd (string replace --regex --all -- $pat '$1…' $_hydro_pwd)
    set -l git (string replace --regex --all -- $pat '$1… ' $$_hydro_git)
    echo -e -n "$_hydro_color_start$hydro_symbol_start$hydro_color_normal$_hydro_color_pwd$pwd$hydro_color_normal $_hydro_color_git$git$hydro_color_normal$_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$_hydro_status$hydro_color_normal "
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Android SDK (Homebrew android-commandlinetools)
set -gx ANDROID_HOME /opt/homebrew/share/android-commandlinetools
set -gx ANDROID_SDK_ROOT $ANDROID_HOME
fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools
