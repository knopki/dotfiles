function fish_starship_init
    status is-interactive || return 10
    type -q starship || return 11
    test -e "$XDG_CONFIG_HOME/starship.toml" || return 12
    ! set -q STARSHIP_SESSION_KEY || return 13
    test "$TERM" -eq dumb || return 14
    starship init fish | source
end
