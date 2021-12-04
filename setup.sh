#!/usr/bin/env bash
# setup emacs config
if [ ! -e /workspace/.emacs ]; then
    cp -a ${HOME}/.emacs* /workspace/
fi
ln -svf /workspace/.emacs ~/.emacs
rm -rf ~/.emacs.d && ln -svf /workspace/.emacs.d ~/.emacs.d

# run emacs damone
export EMACS_SOCKET="${HOME}/.emacs.sock"
emacs --daemon=$EMACS_SOCKET

# run tmate
tmate -S "${HOME}/.tmate.sock" new-session -d emcs
tmate -S "${HOME}/.tmate.sock" wait tmate-ready
TMATE_SESSION=$(tmate -S "${HOME}/.tmate.sock" display -p '#{tmate_ssh}')

# send session to telegram
message="${GITPOD_WORKSPACE_CONTEXT_URL}\n\n${GITPOD_WORKSPACE_URL}\n\n${TMATE_SESSION}"
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" --data "{\"chat_id\":\"$TELEGRAM_CHAT_ID\", \"text\":\"$message\"}" -H 'content-type: application/json'
