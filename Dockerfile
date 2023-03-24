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
    ~/.config/guix/current/bin/guix package -m /src/guix-install.d/manifest.scm'

COPY ./ /src
USER gitpod
WORKDIR /home/gitpod
RUN sudo chown -R gitpod. /src && \
    ln -sv /src/profile/.emacs.d $HOME/.emacs.d && \
    . $HOME/.guix-profile/etc/profile && \
    emacs -q --batch -l $HOME/.emacs.d/init.el -l $HOME/.emacs.d/setup.el && \
    npm install -g yaml-language-server typescript-language-server bash-language-server && \
    pip install python-lsp-server[all] && \
    wget -O /tmp/gh.deb https://github.com/cli/cli/releases/download/v2.24.3/gh_2.24.3_linux_amd64.deb && \
    sudo dpkg -i /tmp/gh.deb
ENV PATH=/workspace/.profile/bin:/src/profile/bin:$PATH
