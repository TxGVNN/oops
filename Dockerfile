FROM gitpod/workspace-full:2022-11-15-17-00-18
USER root
COPY setup.sh emcs setup.el guix-install.sh /usr/local/bin/
RUN yes | bash /usr/local/bin/guix-install.sh
RUN start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /root/.config/guix/current/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot && \
    sleep 1 && \
    sudo -u gitpod guix package -i glibc-locales emacs-next emacs-guix emacs-geiser emacs-geiser-guile direnv \
    ripgrep global screen tmux tmate socat zip dtach dropbear rsync git-crypt && \
    guix gc

USER gitpod
WORKDIR /home/gitpod
ENV DOTS_VERSION=08e6b8cd776d67110d3d86262f5656f191fea423
RUN . "/home/gitpod/.guix-profile/etc/profile" && \
    curl https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.bashrc >> .bashrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.screenrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.emacs && \
    emacs -q --batch -l ~/.emacs -l /usr/local/bin/setup.el && \
    npm install -g yaml-language-server typescript-language-server bash-language-server && \
    pip install python-lsp-server[all]
