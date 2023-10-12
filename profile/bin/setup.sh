#!/usr/bin/env bash
[ "${DEBUG:-0}" -eq 0 ] || set -x

_link(){
    SRC="$1"
    DST="$2"

    if [ -e "$DST" ]; then
        if [ "$(stat "$DST" | head -n1 | cut -f6 -d' ')" == "$SRC" ]; then
            echo "W: $DST is linked, skip"
            return
        fi
        echo "W: $DST is exist, backup it"
        mv -v "$DST" "${DST}.$(date +%F@%R.%s)"
    fi

    ln -svf "$SRC" "$DST"
}

OOPS_DIR="${WORKSPACE}/.oops"
if [ ! -d "$OOPS_DIR" ]; then
    cp /src/oops ${OOPS_DIR} -a
fi
PROFILE="${OOPS_DIR}/profile"

_link "$PROFILE/etc/emacs.d" ~/.emacs.d
_link "$PROFILE/etc/screenrc" ~/.screenrc
_link "$PROFILE/etc/.bashrc" ~/.bashrc
_link "$PROFILE/etc/.bash_profile" ~/.bash_profile
_link "$PROFILE/etc/.bash_logout" ~/.bash_logout

mkdir -p $HOME/.bashrc.d
for i in $(ls -A "$PROFILE/etc/.bashrc.d/"); do
    _link "$PROFILE/etc/.bashrc.d/$i" $HOME/.bashrc.d/$i
done
# source
. "${HOME}/.guix-profile/etc/profile"
export GUIX_LOCPATH="${HOME}/.guix-profile/lib/locale"

# run tmate
tmate -S "${HOME}/.tmate.sock" new-session -d
tmate -S "${HOME}/.tmate.sock" wait tmate-ready
TMATE_SESSION=$(tmate -S "${HOME}/.tmate.sock" display -p '#{tmate_ssh}')

# send session to telegram
message="${GITPOD_WORKSPACE_CONTEXT_URL}\n\n${GITPOD_WORKSPACE_URL}\n\n${TMATE_SESSION}"
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" --data "{\"chat_id\":\"$TELEGRAM_CHAT_ID\", \"text\":\"$message\"}" -H 'content-type: application/json'

# Direnv
mkdir -p ~/.config/direnv
printf '%s\n%s' '[whitelist]' 'prefix = [ "'$WORKSPACE'" ]' > ~/.config/direnv/config.toml

# Python - pyenv
if [ ! -d "${WORKSPACE}/.pyenv" ]; then
    git clone https://github.com/pyenv/pyenv.git "${WORKSPACE}/.pyenv"
    git -C "${WORKSPACE}/.pyenv" checkout ff93c58babd813066bf2d64d004a5cee33c0f27b
fi
ln -svf "${WORKSPACE}/.pyenv" ~/.pyenv

# Nodejs - nvm
if [ ! -d "${WORKSPACE}/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | NVM_DIR="${WORKSPACE}/.nvm" bash
fi
ln -svf "${WORKSPACE}/.nvm" ~/.nvm


if [[ "$(id -u)" -eq 0 ]]; then
    run_as_root() { "$@"; }
else
    run_as_root() { sudo --non-interactive -- "$@"; }
fi


# Codespaces
if [ -n "$CODESPACES" ]; then
    # Codespaces - Docker
    if [ ! -e /var/run/docker.sock ] && [ -e /var/run/docker-host.sock ]; then
        run_as_root ln -svf /var/run/docker-host.sock /var/run/docker.sock
        run_as_root chown vscode. /var/run/docker-host.sock
    fi
fi
