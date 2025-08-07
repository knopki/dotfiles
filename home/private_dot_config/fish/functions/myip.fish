function myip --wraps='curl ifconfig.co' --description 'alias myip curl ifconfig.co'
    curl ifconfig.co
end
