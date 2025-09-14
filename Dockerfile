FROM docker.io/library/debian:trixie-20250908-slim as builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl dirmngr git git-crypt gnupg less libc6 libstdc++6 \
    binutils locales netbase sudo tar wget xz-utils procps && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /src /workspaces

RUN groupadd --gid 1000 robot && \
    useradd --shell /bin/bash --uid 1000 --gid 1000 --create-home robot && \
    echo 'robot ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/robot && \
    chmod 0440 /etc/sudoers.d/robot

COPY guix-install.d /src/oops/guix-install.d
RUN find /src/oops/guix-install.d/gpg_signing_keys -type f -exec gpg --import {} \; && \
    bash /src/oops/guix-install.d/guix-install.sh && \
    start-stop-daemon --user root --pidfile /tmp/guix.sock --background --start --exec /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon -- --build-users-group=guixbuild --disable-chroot -c 2 -M 2 --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://txgvnn.github.io/guxti" && \
    sleep 1 && \
    sudo -H -u robot bash -c 'mkdir -p ~/.config/guix && \
    cp /src/oops/guix-install.d/channels.scm ~/.config/guix/channels.scm && \
    guix pull && \
    ~/.config/guix/current/bin/guix package -m /src/oops/guix-install.d/manifest.scm && \
    rm -rf ~/.cache/guix/inferiors/ && guix gc'


FROM docker.io/library/debian:trixie-20250908-slim
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl dirmngr git git-crypt gnupg less libc6 libstdc++6 \
    binutils locales netbase sudo tar wget xz-utils procps \
    openssh-server openssh-client lsof bash-completion libreadline-dev \
    man screen iproute2 docker-compose rclone file fuse-overlayfs rsync xsel xdotool && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /src /workspaces && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

# Copy guix from the builder
COPY --from=builder /var/guix /var/guix
COPY --from=builder /gnu /gnu
COPY --from=builder /root/.config/guix /root/.config/guix
COPY --from=builder /etc/profile.d/zzz-guix.sh /etc/profile.d/zzz-guix.sh
COPY --from=builder /etc/guix /etc/guix
COPY ./ /src/oops

# Add vscode user and configure Guix
RUN groupadd --gid 1000 vscode \
    && useradd --shell /bin/bash --uid 1000 --gid 1000 --create-home vscode \
    && echo 'vscode ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && chown -hR vscode:vscode /workspaces \
    && mv /var/guix/profiles/per-user/robot /var/guix/profiles/per-user/vscode \
    && chown vscode:vscode -R /var/guix/profiles/per-user/vscode \
    && mkdir /home/vscode/.config/guix -p \
    && ln -s /var/guix/profiles/per-user/vscode/current-guix /home/vscode/.config/guix/current \
    && ln -s /var/guix/profiles/per-user/vscode/guix-profile /home/vscode/.guix-profile \
    && cp /src/oops/guix-install.d/channels.scm /home/vscode/.config/guix/channels.scm \
    && chown vscode:vscode -R /home/vscode/.config \
    && groupadd --system guixbuild \
    && for i in $(seq -w 1 4); do useradd -g guixbuild -G guixbuild -d /var/empty -s "$(which nologin)" -c "GuixBuilder $i" --system "guixbuilder${i}"; done


ENV LANG=en_US.UTF-8
ENV LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

ENV WORKSPACE=/workspaces
ENV PATH=/workspaces/.oops/profile/bin:/src/oops/profile/bin:$PATH

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sleep", "infinity"]

# Set up tmpfs volumes.
VOLUME ["/tmp", "/run"]

ARG REVISION
LABEL org.opencontainers.image.source="https://github.com/TxGVNN/oops"
LABEL org.opencontainers.image.documentation="https://github.com/TxGVNN/oops/blob/${REVISION}/README.md"
LABEL org.opencontainers.image.description="DevContainer, Powerful by Guix!"
