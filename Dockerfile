FROM gitpod/workspace-base:commit-8fc141dbdd92030a435ead06617c6d37651d8312
USER root
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential git autoconf texinfo libgnutls28-dev libxml2-dev libncurses5-dev libjansson-dev libgccjit-9-dev libtool-bin libvterm-dev && \
    git clone https://github.com/emacs-mirror/emacs --depth 1 --branch emacs-28 /src/emacs && \
    cd /src/emacs && \
    ./autogen.sh && \
    ./configure --with-x=no --without-gsettings --with-pop=no --with-modules --with-native-compilation --with-json && \
    NATIVE_FULL_AOT=1 make -j8 && make install && \
    rm -rf /src/emacs
COPY tmate-and-telegram.sh /usr/local/bin

USER gitpod
WORKDIR /home/gitpod
RUN sudo apt-get install -y ripgrep global screen tmux tmate socat zip dtach && \
    wget https://txgvnn.github.io/sh/dots && \
    bash dots && \
    emacs -q --batch -l ~/.emacs && \
    echo "(setq warning-suppress-types '((comp)))" > ~/.emacs.d/personal.el