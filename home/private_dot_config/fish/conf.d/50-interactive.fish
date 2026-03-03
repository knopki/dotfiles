function _atuin_init
    status is-interactive || return 10
    type -q atuin || return 11
    test -e "$XDG_CONFIG_HOME/atuin/config.toml" || return 12

    atuin init fish --disable-up-arrow --disable-ctrl-r | source

    bind ctrl-alt-r _atuin_search
    if bind -M insert >/dev/null 2>&1
        bind -M insert ctrl-alt-r _atuin_search
    end
end

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

function _apply_theme
    status is-interactive || return 10
    if not set -q fish_color_normal
        fish_config theme save "Dracula Official"
    end
end

status is-interactive
begin
    _fzf_init
    _atuin_init
    _starship_init
    _register_abbr
    _apply_theme
end
