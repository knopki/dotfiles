function stl --wraps='s systemctl' --description 'alias stl sudo systemctl'
    systemctl systemctl $argv
end
