function _fzf_init
    status is-interactive || return 10
    type -q fzf || return 11

    # Register fzf and bind:
    #  - ctrl+t list files+folders in current directory
    #  - ctrl+r search history of shell commands
    #  - alt+c fuzzy change directory
    fzf --fish | source
end

function _starship_init
    status is-interactive || return 10
    type -q starship || return 11
    test -e "$XDG_CONFIG_HOME/starship.toml" || return 12
    test "$TERM" = dumb && return 14
    starship init fish | source
end

function _register_abbr
    status is-interactive || return 10
    abbr --add -- o xdg-open
    abbr --add -- gst "git st"
    abbr --add -- gco "git checkout"
end

function _register_eza_aliases
    status is-interactive || return 10
    type -q eza || return 11
    alias ls='eza -al --color=always --group-directories-first --icons=always' # preferred listing
    alias la='eza -a --color=always --group-directories-first --icons=always' # all files and dirs
    alias ll='eza -l --color=always --group-directories-first --icons=always' # long format
    alias lt='eza -aT --color=always --group-directories-first --icons=always' # tree listing
    alias l.="eza -a | grep -e '^\.'" # show only dotfiles
end

status is-interactive
begin
    _fzf_init
    _starship_init
    _register_abbr
    _register_eza_aliases
end
