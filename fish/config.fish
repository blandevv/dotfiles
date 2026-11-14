if status is-interactive
    # Commands to run in interactive sessions can go here
    if not functions -q fisher
        curl -sL https://git.io/fisher | source
        fisher install jorgebucaran/fisher
    end
end

# if not set -q TMUX
#     if type -q tmux
#         tmux new-session -A -s main
#     else if type -q zellij
#         zellij attach -c main
#     end
# end

starship init fish | source
zoxide init fish | source
fzf --fish | source
atuin init fish | source

set -x PATH $HOME/.cargo/bin $PATH

set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'

carapace _carapace | source

set -g fish_greeting ""

# fastfetch

fish_vi_key_bindings

set -gx EDITOR nvim
set -gx VISUAL nvim

alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
alias fzfnvim='nvim (fzf --preview="bat --theme=gruvbox-dark --color=always {}")'

alias cat="bat"
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --icons --git"
alias ff="fastfetch"
alias n="nvim"
alias l="ll"
alias lg="lazygit"
alias py="python"
alias bo="brew outdated"
alias bu="brew upgrade"

set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Palette follows the active ghostty theme (ghostty/themes/<name>).
set -l theme_palette monochrome

set -l foreground
set -l selection
set -l comment
set -l red
set -l orange
set -l yellow
set -l green
set -l purple
set -l cyan
set -l pink

switch $theme_palette
    case monochrome
        set foreground F2F2F2 normal
        set selection 2E2E2E normal
        set comment 7C7C7C brblack
        set red 8F8F8F red
        set orange A6A6A6 orange
        set yellow DEDEDE yellow
        set green B8B8B8 green
        set purple CACACA purple
        set cyan A6A6A6 cyan
        set pink CACACA magenta
    case gentleman
        set foreground F3F6F9 normal
        set selection 263356 normal
        set comment 8394A3 brblack
        set red CB7C94 red
        set orange DEBA87 orange
        set yellow FFE066 yellow
        set green B7CC85 green
        set purple A3B5D6 purple
        set cyan 7AA89F cyan
        set pink FF8DD7 magenta
    case '*'
        echo "fish: unknown theme_palette '$theme_palette'" >&2
end

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $green
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $green
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
