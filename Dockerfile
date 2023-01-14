FROM gitpod/workspace-full:2022-11-15-17-00-18
USER root
COPY ./ /src
RUN yes | bash /src/guix-install.sh
RUN start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /root/.config/guix/current/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot && \
    sleep 1 && \
    sudo -u gitpod guix pull --commit=ef0613a81dca73602e702cb5f5444ee94566f983 && \
    sudo -u gitpod ~/.config/guix/current/bin/guix package -L /src -m /src/manifest.scm && \
    guix gc

USER gitpod
WORKDIR /home/gitpod
ENV DOTS_VERSION=08e6b8cd776d67110d3d86262f5656f191fea423
RUN . "$HOME/.guix-profile/etc/profile" && \
    curl https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.bashrc >> .bashrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.screenrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.emacs && \
    mkdir ~/.emacs.d -p && \
    cp /src/early-init.el ~/.emacs.d/ && \
    emacs -q --batch -l ~/.emacs -l /src/setup.el && \
    npm install -g yaml-language-server typescript-language-server bash-language-server && \
    pip install python-lsp-server[all] && \
    printf '%s\n' "if ! pgrep guix-daemon > /dev/null; then" \
    "sudo start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /root/.config/guix/current/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot" "fi" >> $HOME/.bashrc.d/900-guix-daemon && \
    printf '%s\n' 'export PATH=/src/bin:$PATH' > $HOME/.bashrc.d/999-me
