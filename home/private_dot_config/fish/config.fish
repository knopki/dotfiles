#!/usr/bin/env fish

set -g fish_greeting ""
set -x fish_history "$(hostname -s | tr - _)"
set -g fish_key_bindings fish_hybrid_key_bindings
