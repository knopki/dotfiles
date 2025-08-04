#!/usr/bin/env fish

set -x fish_history "$(hostname -s)"

#
# Interactive init
#
status is-interactive
begin
    fish_atuin_init
    fish_starship_init
end
