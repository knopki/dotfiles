if type -q fzf; and type -q fd
    set -x FZF_DEFAULT_COMMAND "fd --hidden --type l --type f --type d --exclude .git --exclude .cache"
    set -x FZF_CTRL_T_OPTS "--walker-skip .git,node_modules,target --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    if type -q bat
        set -x FZF_CTRL_T_OPTS "$FZF_CTRL_T_OPTS --preview 'bat -n --color=always {}'"
    end
    set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -x FZF_CTRL_R_OPTS "--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --color header:italic --header 'Press CTRL-Y to copy command into clipboard'"
    set -x FZF_ALT_C_OPTS "--walker-skip .git,node_modules,target --preview 'tree -C {}'"
end
