if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

function fish_greeting
end

set -x fish_history "$(hostname -s | tr - _)"
set -g fish_key_bindings fish_hybrid_key_bindings
