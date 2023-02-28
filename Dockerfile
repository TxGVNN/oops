FROM gitpod/workspace-full:2022-11-15-17-00-18
USER root
COPY ./guix-install.sh /src/
RUN yes | bash /src/guix-install.sh
COPY ./ /src
RUN start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /root/.config/guix/current/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot && \
    sleep 1 && \
    sudo -u gitpod mkdir -p ~/.config/guix && \
    sudo -u gitpod cp /src/channels.scm ~/.config/guix/channels.scm && \
    sudo -u gitpod guix pull && \
    sudo -u gitpod ~/.config/guix/current/bin/guix package -m /src/manifest.scm

USER gitpod
WORKDIR /home/gitpod
ENV DOTS_VERSION=da88cff353ed47769300b73833f93cc36ea6fda6
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
