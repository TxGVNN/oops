# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	    # We have color support; assume it's compliant with Ecma-48
	    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	    # a case would tend to support setf rather than setaf.)
	    color_prompt=yes
    else
	    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

[ "$GTX_DIR" ] || GTX_DIR="${PWD}/../"
if ! echo "$PATH" | grep -q "$GTX_DIR" > /dev/null 2>&1; then
    export PATH=$PATH:$GTX_DIR/bin
fi
#PS1
color='32'
[ "$(id -u)" -ne 0 ] || color='31'

if ! declare -f "__git_ps1" >/dev/null; then
    function __git_ps1(){ echo "";}
fi
export GIT_PS1_SHOWDIRTYSTATE=true

# PS9 will keeping old PS1 before run new bash inside a bash,
# export PS9=$PS1 before run new bash
if [ -n "$PS9" ]; then
    PS1=$PS9
else
    PS1="\$(__service_ps)\n\[\e[0;${color}m\]\342\224\214\[\e[1;30m\](\[\e[0;${color}m\]\u\[\e[0;36m\]@\h\[\e[1;30m\])\$(if [[ \$? == 0 ]]; then echo \"\[\e[1;32m\]\342\224\200\"; else echo \"\[\e[1;31m\]\342\224\200\"; fi)\[\e[0m\]\[\e[1;30m\](\[\e[0;34m\]\w\[\e[1;30m\])\342\224\200(\[\e[0;33m\]\t\[\e[1;30m\]\[\e[1;30m\])\$(__git_ps1)\n\[\e[0;${color}m\]\342\224\224>\[\e[0m\]"
fi

function __service_ps(){
    local ret=$?
    # torsock on
    if env | grep torsocks -q ; then
        printf "\342\224\200\e[1;30m(\e[1;30mtor\e[1;30m)\e[0m"
    fi
    if [ -n "$GUIX_ENVIRONMENT" ]; then
        printf "\342\224\200\e[1;30m(\e[1;30m$GUIX_ENVIRONMENT\e[1;30m)\e[0m"
    fi
    return $ret
}

function ps1(){
    if [[ $PS1 != *"$1"* ]]; then
        PS1="\342\224\200\[\e[1;30m\](\[\e[0;35m\]"$1"\[\e[1;30m\])\[\e[0m\]"$PS1
    fi
}

function cdenv(){
    if [ -z "$1" ]; then
        cd || exit 1
    else
        cd "$1"
    fi

    # .bin #TxGVNN
    if [ -e .bin ]; then
        if [[ $PATH != *"$(pwd)/.bin"* ]]; then
            ps1 ".bin"
            export PATH=$(pwd)/.bin:$PATH
        fi
        if [ -e .bin/env ]; then
            . .bin/env
        fi
    fi

    # Makefile
    if [ -e Makefile ]; then
        ps1 "make"
    else
        PS1=$(echo $PS1 | sed 's/\\342\\224\\200\\\[\\e\[1;30m\\\](\\\[\\e\[0;35m\\\]make\\\[\\e\[1;30m\\\])//g')
    fi
    # direnv
    if [ -n $DIRENV_DIR ]; then
        ps1 "envrc"
    else
        PS1=$(echo $PS1 | sed 's/\\342\\224\\200\\\[\\e\[1;30m\\\](\\\[\\e\[0;35m\\\]envrc\\\[\\e\[1;30m\\\])//g')
    fi

    # virtualenv
    if [ -e bin ]; then
        if [[ $PATH != *"$(pwd)/bin"* ]]; then
            ps1 bin
            export PATH=$(pwd)/bin:$PATH
        fi
        if [ -e bin/activate ]; then
            . bin/activate
        fi
    fi

    # vagrant
    if [ -e Vagrantfile ]; then
        if [[ $PS1 != *"vagrant"* ]]; then
            ps1 vagrant
        fi
    else
        PS1=$(echo $PS1 | sed 's/\\342\\224\\200\\\[\\e\[1;30m\\\](\\\[\\e\[0;35m\\\]vagrant\\\[\\e\[1;30m\\\])//g')
    fi
}

if [ -z "$TMPDIR" ]; then
    export TMPDIR=/tmp
fi
function cdtmp(){
    cd "$(mktemp -d -t ${USER}_$(date +%Y%m%d-%H%M)_XXX)" || exit 1
}

function lstmp(){
    ls "$TMPDIR/$USER"*
}

function mkcd(){
    if [ $# -ne 1 ]; then
        echo "Usage: mkcd DIR"
    fi
    mkdir "$1" && cd "$1"
}
# direnv
if type -p direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# SSH and screen
function sshscreen(){
    ssh "$@" -t 'if screen -ls | grep gtx -q ; then screen -x gtx ;else screen -S gtx ;fi'
}

# SSH and screen
function sshtmux(){
    ssh "$@" -t 'if tmux ls | grep gtx -q ; then tmux at -t gtx ;else tmux new -s gtx ;fi'
}
export SSH_DIR="${HOME}/.ssh"
use-ssh(){
    ssh_key="$USER@$HOSTNAME.priv"
    if [ -e "${SSH_DIR}/$1" ]; then
        ssh_key="${SSH_DIR}/$1"
    elif [ -e "${PWD}/$1" ]; then
        ssh_key="${PWD}/$1"
    elif [ -e "$1" ]; then
        ssh_key="$1"
    else
        echo "What is $1?"
        return 1
    fi
    ssh_key=$(readlink -f "$ssh_key")
    file="$TMPDIR/.${LOGNAME}_ssh_${ssh_key////_}.tmp"
    if [ -z "$2" ] && [ -e "$file" ]; then
        export SSH_AUTH_SOCK="$(readlink -f $file)"
        ps1 "ssh:$ssh_key"
        return 0
    fi
    eval $(ssh-agent)
    ssh-add "${ssh_key}"
    ln -svf "$SSH_AUTH_SOCK" "$file" >& /dev/null
    ps1 "ssh:$ssh_key"
}
## default
export SSH_AUTH_SOCK="$TMPDIR/.${LOGNAME}_ssh_${HOME////_}.ssh_{USER}@${HOSTNAME}.priv.tmp"

_use-ssh(){
    local cur prev words cword opts
    _get_comp_words_by_ref -n : cur prev words cword
    COMPREPLY=()
    opts=""
    if [[ ${#toks[@]} -ne 0 ]]; then
        compopt -o filenames 2> /dev/null;
        COMPREPLY+=("${toks[@]}");
    fi
    if [[ ${cword} -eq 1 ]];then
        opts=$(find "${SSH_DIR}/" -name \*@\* -exec basename {} \;)
    fi
    _filedir
    COMPREPLY+=( $(compgen -W "$opts" -- "${cur}"))
}

complete -F _use-ssh use-ssh

# ansible
function use-ansible(){
    DIR="${HOME}/.ansible"
    VERSION="$1"
    if [ ! "$1" ] || [ ! -d "${DIR}/${VERSION}" ]; then
        echo -e "\e[31mSupported version:\e[0m"
        ls -1 "${DIR}"
    else
        if [ ! -e "${DIR}/${VERSION}/bin/activate" ]; then
            echo "Invalid" && return 1
        fi
        source "${DIR}/${VERSION}/bin/activate"
    fi
}

# nodejs
function use-node(){
    export NVM_DIR="$HOME/.nvm"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        echo "nvm is not found!"
        echo "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash"
        return 1
    fi
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    ps1 "use:node"
    echo "nvm is ready! Run \"nvm use node\" to use default"
}

# go
function use-go(){
    export GVM_ROOT="$HOME/.gvm"
    if [ ! -s "$GVM_ROOT/scripts/gvm" ]; then
        echo "gvm is not found! apt-get install golang first (bootstrap)"
        echo 'bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)'
        return 1
    fi
    source "$GVM_ROOT/scripts/gvm"
    ps1 "use:go"
    echo "gvm is ready! Run \"gvm use go1.13\" example"
}

# python
function use-python(){
    export PYENV_ROOT="$HOME/.pyenv"
    if [ ! -s "$PYENV_ROOT" ]; then
        echo "pyenv is not found!"
        echo "git clone https://github.com/pyenv/pyenv.git ~/.pyenv"
        echo "cd ~/.pyenv && src/configure && make -C src"
        return 1
    fi
    ps1 "use:python"
    # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
    export PATH="$PATH:$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

# ruby
function use-ruby(){
    export RVM_DIR="$HOME/.rvm"
    if [ ! -s "$RVM_DIR/scripts/rvm" ]; then
        echo "rvm is not found! curl -sSL https://get.rvm.io | bash -s stable"
        return 1
    fi
    ps1 "use:ruby"
    # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
    export PATH="$PATH:$HOME/.rvm/bin"
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
}

export DIR_KUBE="$HOME/.kube/load"
function use-kube(){
    if [ ! "$1" ] || [ ! -e "$DIR_KUBE/$1" ]; then
        echo "Please select:"
        ls "$DIR_KUBE"
    else
        export KUBECONFIG="$DIR_KUBE/$1"
        ps1 "kube:$1"
        echo "export KUBECONFIG=${DIR_KUBE}/$1"
    fi
}
_use-kube(){
    local cur prev words cword opts
    _get_comp_words_by_ref -n : cur prev words cword
    COMPREPLY=()
    opts=""
    if [[ ${cword} -eq 1 ]];then
        opts=$(ls $DIR_KUBE)
    fi
    COMPREPLY=( $(compgen -W "$opts" -- "${cur}"))
}
complete -F _use-kube use-kube

function minikube(){
    MINIKUBE_BIN=$(which minikube 2>/dev/null)
    # Patch /etc/bash_completion.d/gcloud with s,$1,/usr/bin/gcloud,g'
    if [[ "$1" == "start" ]]; then
        export KUBECONFIG="$DIR_KUBE/../config"
        rm "$KUBECONFIG" -f
        $MINIKUBE_BIN $@
        ret=$?
        [ $ret -ne 0 ] && return $ret
        profile=$3
        name=minikube-${profile:-minikube}
        mv "$DIR_KUBE/../config" "$DIR_KUBE/${name}"
        echo -e "\nRunning ~\e[32muse-kube ${name}\e[0m~"
        use-kube "${name}"
        return $ret
    fi
    $MINIKUBE_BIN $@
}


function kind(){
    KIND_BIN=$(which kind 2>/dev/null)
    if [[ "$1" == "create" ]]; then
        export KUBECONFIG="$DIR_KUBE/../config"
        rm "$KUBECONFIG" -f
        $KIND_BIN $@
        ret=$?
        [ $ret -ne 0 ] && return $ret
        profile=$(echo $@ | sed -En "s/.*--name=?\s?(.+?)\s*$/\1/p" | cut -f1 -d" ")
        name=kind-${profile:-kind}
        mv "$DIR_KUBE/../config" "$DIR_KUBE/${name}"
        echo -e "\nRunning ~\e[32muse-kube ${name}\e[0m~"
        use-kube "${name}"
        return $ret
    fi
    $KIND_BIN $@
}

AWS_DIR="$HOME/.aws/load"
function use-aws(){
    if [ ! "$1" ] || [ ! -e "$AWS_DIR/$1" ]; then
        echo "Please select:"
        ls "$AWS_DIR"
    else
        export AWS_SHARED_CREDENTIALS_FILE="$AWS_DIR/$1"
        ps1 "aws:$1"
        echo "export AWS_SHARED_CREDENTIALS_FILE=${AWS_DIR}/$1"
    fi
}
_use-aws(){
    local cur prev words cword opts
    _get_comp_words_by_ref -n : cur prev words cword
    COMPREPLY=()
    opts=""
    if [[ ${cword} -eq 1 ]];then
        opts=$(ls $AWS_DIR)
    fi
    COMPREPLY=( $(compgen -W "$opts" -- "${cur}"))
}
complete -F _use-aws use-aws

KOPS_BIN=$(which kops 2>/dev/null)
function kops(){
    # Patch /etc/bash_completion.d/gcloud with s,$1,/usr/bin/gcloud,g'
    if [[ "$1" == "export" ]]; then
        export KUBECONFIG="$DIR_KUBE/../config"
        rm "$KUBECONFIG" -f
        $KOPS_BIN $@
        ret=$?
        [ $ret -ne 0 ] && return $ret
        profile=$4
        name=kops-${profile}
        mv "$DIR_KUBE/../config" "$DIR_KUBE/${name}"
        echo -e "\nRunning ~\e[32muse-kube ${name}\e[0m~"
        use-kube "${name}"
        return $ret
    fi
    $KOPS_BIN $@
}
function today() {
    mkdir -p ~/worklogs/$(date +%F)
    cd ~/worklogs/$(date +%F)
}
# alias
alias cd="cdenv"
alias em="emacs -nw"
alias psc="ps xawf -eo pid,ppid,user,cgroup,args"
stty -ixon

## Check pseudoterminal or not?
export TERM=xterm-256color
if [[ $(tty) != */dev/pts/* ]]; then
    export TERM=linux
fi
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export LOCATE_PATH=~/.locate.db
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

export PATH=/workspace/.profile/bin:/src/profile/bin:$PATH
if [ -d "/var/run/user/$(id -u)" ]; then
    export XDG_RUNTIME_DIR=/var/run/user/$(id -u)
fi
for i in $(ls -A $HOME/.bashrc.d/); do source $HOME/.bashrc.d/$i; done
