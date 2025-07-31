function fish_atuin_init
    status is-interactive || return 10
    type -q atuin || return 11
    test -e "$XDG_CONFIG_HOME/atuin/config.toml" || return 12
    atuin init fish --disable-up-arrow | source
end
