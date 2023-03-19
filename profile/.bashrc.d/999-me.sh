if ! screen -ls | grep main -q; then
    screen -S main -dm emcs
fi
