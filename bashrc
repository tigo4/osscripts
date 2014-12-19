# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000000
HISTFILESIZE=20000000

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
    xterm-color) color_prompt=yes;;
esac
color_prompt=yes

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
    ##PS1='${debian_chroot:+($debian_chroot)}\[\033[0;37m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[0;37m\]\[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\$ '
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

# some more ls aliases
##alias ll='ls -alF'
##alias la='ls -A'
##alias l='ls -CF'

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


alias f='find'
alias less='clear && less'
alias sc='screen'
alias folderpdf='find . -type f | xargs -I {} epdfview {}'
alias pdf='epdfview'
alias b0='sudo /etc/osscripts/brig 0'
alias b10='sudo /etc/osscripts/brig 10'
alias b20='sudo /etc/osscripts/brig 20'
alias b30='sudo /etc/osscripts/brig 30'
alias b40='sudo /etc/osscripts/brig 40'
alias b50='sudo /etc/osscripts/brig 50'
alias b60='sudo /etc/osscripts/brig 60'
alias b70='sudo /etc/osscripts/brig 70'
alias b80='sudo /etc/osscripts/brig 80'
alias b130='sudo /etc/osscripts/brig 130'
alias b150='sudo /etc/osscripts/brig 150'
alias b170='sudo /etc/osscripts/brig 170'
alias v='vi'
alias screen='export TERM=xterm && screen'
alias zs='export TERM=xterm && screen -c /home/tigo/zscreenrc'
alias elinks='export TERM=xterm && elinks'
alias ps1='PS1=$(echo $PS1|sed "s/w/W/g")" ";'
alias pidgin='export NSS_SSL_CBC_RANDOM_IV=0; xterm -e nohup pidgin'
alias b='sensors | grep -vi virtu && bat | grep rate | grep -v His && bat | grep time && bat | grep percent && bat | grep state'
alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
##alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT1'
alias ..='cd ..'
alias all='source /etc/osscripts/all'
###alias off='source /home/root1/off'
alias dns='sudo /etc/osscripts/dns'
alias gmail='/etc/osscripts/gmail'
alias e='exit'
alias sky='/etc/osscripts/zskype'
alias spen='sudo /etc/osscripts/spen'
alias revspen='sudo /etc/osscripts/revspen'
alias tinyspen='sudo /etc/osscripts/tinyspen'
alias eclipse='eclipse -vmargs -Djava.net.preferIPv4Stack=true'
##alias putlap='sudo /etc/osscripts/putlap'
alias g='gmate'
alias gts='git status'
alias gtd='git diff'
alias gtl='git log --name-only'
alias gtb='git branch'
alias cp='cp -i'
alias mv='echo MOVINg!; read zinp; mv -i'
alias s='sync'
alias rm='echo REMOVING!; read zinp; rm -I'
alias d='df -h'
alias pwersav='sudo /etc/osscripts/pwersav'
alias off='sudo /etc/osscripts/off'
alias 11='pwd && ls -lh'
alias 11a='pwd && ls -alh'
alias l='pwd && ls -1'
alias 1="pwd && ls -1"
alias 1d="pwd && ls -la downloads/"
alias m='dmesg|tail'
alias a='tail /var/log/syslog'
alias kterm='kterm -bg black -fg green -sl 20000 -sb -fn 10x20'
alias wifi='sudo /etc/osscripts/wifi'
alias pagecache='sudo bash -ci "echo 1 > /proc/sys/vm/drop_caches"'
setxkbmap us

alias brig='/etc/osscripts/brig 80'
alias copia='cp'

alias beep='paplay /usr/share/sounds/KDE-Im-Message-In.ogg'

##export JAVA_HOME="/usr/lib/jvm/java-6-openjdk-amd64"

xmodmap /home/tigo/.Xmodmap



unset GNOME_KEYRING_PID
unset GNOME_KEYRING_CONTROL

alias c='sync && clear'

function cd() {
	builtin cd "$@" && l
}

export PROMPT_COMMAND="echo '*                                                                                          ' && echo sync... && sync && echo sync done && read dummy && clear && tput cup 4 4 && echo -e \"\n\n\n\" && tput el"

_root_command()
{
    local PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
    local root_command=$1
    _command $1 $2 $3
}
complete -F _root_command sd



alias sd='sudo'

trap 'printf "\ek%s\e\\" "`history 1` $PWD"' DEBUG

echo "bem-vindo"
pwd


# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=/media/data/temp/cocos2d-js-v3.1/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH

# Add environment variable ANT_ROOT for cocos2d-x
export ANT_ROOT=/usr/bin
export PATH=$ANT_ROOT:$PATH

