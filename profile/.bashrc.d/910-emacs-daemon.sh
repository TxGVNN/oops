# Run emacs daemon
if ! pgrep emacs > /dev/null; then
    emacs --daemon
fi
