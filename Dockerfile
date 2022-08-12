FROM gitpod/workspace-full:2022-08-04-13-40-17
USER root
RUN install-packages build-essential git autoconf texinfo libgnutls28-dev libxml2-dev libncurses5-dev libjansson-dev libtool-bin libvterm-dev && \
    git clone https://github.com/emacs-mirror/emacs --depth 1 --branch emacs-28 /src/emacs && \
    cd /src/emacs && \
    ./autogen.sh && \
    ./configure --with-x=no --without-gsettings --with-pop=no --with-modules --with-json && \
    make -j8 && make install && \
    rm -rf /src/emacs
COPY setup.sh emcs /usr/local/bin/

USER gitpod
WORKDIR /home/gitpod
ENV DOTS_VERSION=4792426aabfb513d8ea97d3b0899b86adcf2ec71
RUN sudo install-packages direnv ripgrep global screen tmux tmate socat zip dtach dropbear rsync git-crypt && \
    curl https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.bashrc >> .bashrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.screenrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.emacs && \
    emacs -q --batch -l ~/.emacs
