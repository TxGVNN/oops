[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# direnv
if type -p direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

if [[ -n $SSH_CONNECTION ]] && [[ -d $GITPOD_REPO_ROOT ]]; then
    cd "$GITPOD_REPO_ROOT" || return ;
fi
