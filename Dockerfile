FROM gitpod/workspace-base:2022-11-15-17-00-18
USER root
COPY ./guix-install.d /src/guix-install.d
RUN find /src/guix-install.d/gpg_signing_keys -type f -exec gpg --import {} \; && \
    bash /src/guix-install.d/guix-install.sh && \
    start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot -c 2 -M 2 && \
    sleep 1 && \
    sudo -H -u gitpod bash -c 'mkdir -p ~/.config/guix && \
    cp /src/guix-install.d/channels.scm ~/.config/guix/channels.scm && \
    guix pull && \
    ~/.config/guix/current/bin/guix package -m /src/guix-install.d/manifest.scm && \
    guix gc'

COPY ./ /src
USER gitpod
WORKDIR /home/gitpod
RUN sudo chown -R gitpod. /src && \
    mkdir -p /home/gitpod/.config/direnv && \
    printf '%s\n%s' '[whitelist]' 'prefix = [ "/workspace" ]' > /home/gitpod/.config/direnv/config.toml
ENV PATH=/workspace/.profile/bin:/src/profile/bin:$PATH
