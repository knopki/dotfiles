function utl --wraps='systemctl --user' --description 'alias utl systemctl --user'
    systemctl --user $argv
end
