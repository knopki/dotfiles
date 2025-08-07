function ns --wraps='n search --no-update-lock-file' --description 'alias ns nix search --no-update-lock-file'
    nix search --no-update-lock-file $argv
end
