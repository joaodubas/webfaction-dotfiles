# Easier navigation: .., ..., ~ and -
alias ..="cd .."
alias ...="cd ../.."


# Easier file & directory listing
alias l='ls -CF'  # directories and files in columns
alias la='ls -A'  # directories and files incl. hidden in columns
alias ll='ls -alF'  # everything with extra info as a list
alias lsd='ls -l | grep "^d"'  # only directories as a list


alias c="clear"
alias g="git"
alias v="vim"
alias sbrc="source ~/.bashrc"


# Always use color output for `ls`
if [[ "$OSTYPE" =~ ^darwin ]]; then
    alias ls="command ls -G"
else
    alias ls="command ls --color"
    export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
fi


# Enhanced WHOIS lookups
alias whois="whois -h whois-servers.net"


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Easy docker container removal
alias docker-rmc="docker ps -a | grep Exit | cut -d' ' -f1 | xargs docker rm"
alias docker-umount="sudo umount -l $(grep 'aufs' /proc/mounts | awk '{print$2}' | sort -r)"

# Checkers
function linters() {
    local image="joaodubas/checkers:latest"
    local pybase="/usr/local/bin"
    local nodebase="/usr/local/lib/node_modules/js-checkers/node_modules/.bin"
    local dockerbase="docker run -i -t -v $(pwd):/opt/app -w /opt/app"
    $dockerbase -entrypoint $pybase/$1 $image $2
}
function pylint() {
    linters 'pylint' $1
}
function pep8() {
    linters 'pep8' $1
}
function pyflakes() {
    linters 'pyflakes' $1
}
function jshint() {
    linters 'jshint' $1
}
function csslint() {
    linters 'csslint' $1
}

# maestro orchestration
function maestro-ng() {
    local image="joaodubas/maestro:latest"
    local cmd="docker run -i -t -v $(pwd):/opt/host --rm"
    $cmd $image $1
}

# JavaScript shell
function js() {
    docker run \
        -i \
        -t \
        --rm \
        -v $(pwd):/opt/app \
        --entrypoint js \
        joaodubas/spidermonkey:latest \
        $*
}

# Load .bash_personal
if [ -f .bash_personal ]; then
    source .bash_personal
fi
