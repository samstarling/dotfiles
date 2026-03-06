# Mise
/Users/sam/.local/bin/mise activate fish | source

# Brew
/opt/homebrew/bin/brew shellenv fish | source

if status is-interactive
    zoxide init fish | source
end

abbr -a gs git status
abbr -a gp git push
abbr -a gl git pull
abbr -a gd git diff

alias ls "eza --group-directories-first --git"
alias ll "eza --group-directories-first --git -l"

set -U fish_color_no_newline --background=black black
set -U hydro_symbol_prompt "›"
set -U hydro_color_prompt 808080
set -U hydro_fetch false
set -U hydro_color_pwd 808080
set -U hydro_color_git fab387
set -U hydro_symbol_git_dirty " ±"
set -U hydro_cmd_duration_threshold 9999999
