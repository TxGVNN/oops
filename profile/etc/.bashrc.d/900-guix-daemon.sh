if ! pgrep guix-daemon > /dev/null; then
    sudo start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /root/.config/guix/current/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://txgvnn.github.io/guxti"
fi
