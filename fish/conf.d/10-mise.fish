if type -q mise
    mise activate fish --shims | source
    if status is-interactive
        mise activate fish | source
    end
end
