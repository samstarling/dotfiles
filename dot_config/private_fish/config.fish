# Mise
if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate fish | source
end

# Brew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
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

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
