function sctl --wraps='sudo systemctl' --description 'alias sctl sudo systemctl'
    sudo systemctl $argv
end
