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

PROFILE="/workspace/.profile"
if [ ! -d "$PROFILE" ]; then
    cp /src/profile ${PROFILE} -a
fi

_link "$PROFILE/.emacs.d" ~/.emacs.d
_link "$PROFILE/.screenrc" ~/.screenrc
_link "$PROFILE/.bashrc" ~/.bashrc
_link "$PROFILE/.bash_profile" ~/.bash_profile
_link "$PROFILE/.bash_logout" ~/.bash_logout

for i in $(ls -A "$PROFILE/.bashrc.d/"); do
    _link "$PROFILE/.bashrc.d/$i" $HOME/.bashrc.d/$i
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

# Python - pyenv
if [ ! -d "/workspace/.pyenv" ]; then
    git clone https://github.com/pyenv/pyenv.git /workspace/.pyenv
    git -C /workspace/.pyenv checkout ff93c58babd813066bf2d64d004a5cee33c0f27b
fi
ln -svf /workspace/.pyenv ~/.pyenv
