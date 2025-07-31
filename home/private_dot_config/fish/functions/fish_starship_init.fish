function fish_starship_init
    status is-interactive || return 10
    type -q starship || return 11
    test -e "$XDG_CONFIG_HOME/starship.toml" || return 12
    test "$TERM" = dumb || return 14
    starship init fish | source
end
