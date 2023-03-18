FROM gitpod/workspace-full:2022-11-15-17-00-18
USER root
COPY ./guix-install.sh /src/
RUN yes | bash /src/guix-install.sh
COPY ./channels.scm /src
COPY ./manifest.scm /src
RUN start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /root/.config/guix/current/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot -c 4 -M 4 && \
    sleep 1 && \
    sudo -u gitpod mkdir -p ~/.config/guix && \
    sudo -u gitpod cp /src/channels.scm ~/.config/guix/channels.scm && \
    sudo -u gitpod guix pull && \
    sudo -u gitpod ~/.config/guix/current/bin/guix package -m /src/manifest.scm

COPY ./ /src
USER gitpod
WORKDIR /home/gitpod
RUN sudo chown -R gitpod. /src && \
    ln -sv /src/profile/.emacs.d $HOME/.emacs.d && \
    for i in $(ls -A /src/profile/.bashrc.d/); do ln -svf /src/profile/.bashrc.d/$i $HOME/.bashrc.d/$i; done && \
    . $HOME/.guix-profile/etc/profile && \
    emacs -q --batch -l $HOME/.emacs.d/init.el -l $HOME/.emacs.d/setup.el && \
    npm install -g yaml-language-server typescript-language-server bash-language-server && \
    pip install python-lsp-server[all] && \
    wget -O /tmp/gh.deb https://github.com/cli/cli/releases/download/v2.24.3/gh_2.24.3_linux_amd64.deb && \
    sudo dpkg -i /tmp/gh.deb
