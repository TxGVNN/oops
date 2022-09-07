FROM gitpod/workspace-full:2022-08-04-13-40-17
USER root
RUN install-packages build-essential git autoconf texinfo libgnutls28-dev libxml2-dev libncurses5-dev libjansson-dev libtool-bin libvterm-dev && \
    git clone https://github.com/emacs-mirror/emacs --depth 1 --branch emacs-28 /src/emacs && \
    cd /src/emacs && \
    ./autogen.sh && \
    ./configure --with-x=no --without-gsettings --with-pop=no --with-modules --with-json && \
    make -j8 && make install && \
    rm -rf /src/emacs
COPY setup.sh emcs setup.el /usr/local/bin/

USER gitpod
WORKDIR /home/gitpod
ENV DOTS_VERSION=b1b4b000ad52f9b7b54ad998c1d147522bbc1e3a
RUN sudo install-packages direnv ripgrep global screen tmux tmate socat zip dtach dropbear rsync git-crypt && \
    curl https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.bashrc >> .bashrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.screenrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.emacs && \
    emacs -q --batch -l ~/.emacs -l /usr/local/bin/setup.el && \
    npm install -g yaml-language-server typescript-language-server bash-language-server && \
    pip install python-lsp-server[all]
