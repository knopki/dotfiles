function fish_fzf_init
    status is-interactive || return 10
    type -q fzf || return 11

    # Register fzf and bind:
    #  - ctrl+t list files+folders in current directory
    #  - ctrl+r search history of shell commands
    #  - alt+c fuzzy change directory
    fzf --fish | source
end
