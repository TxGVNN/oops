FROM gitpod/workspace-full:2022-02-10-14-27-20
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
ENV DOTS_VERSION=9e7389cdb2427f75e257e208a1c60a51aca7e991
RUN sudo install-packages ripgrep global screen tmux tmate socat zip dtach dropbear rsync git-crypt && \
    curl https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.bashrc >> .bashrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.screenrc && \
    wget https://raw.githubusercontent.com/TxGVNN/dots/${DOTS_VERSION}/.emacs && \
    emacs -q --batch -l ~/.emacs
