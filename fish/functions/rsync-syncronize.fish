function rsync-syncronize --wraps='rsync -avzu --delete --progress -h' --description 'alias rsync-syncronize rsync -avzu --delete --progress -h'
    rsync -avzu --delete --progress -h $argv
end
