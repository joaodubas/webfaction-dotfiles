#!/usr/bin/env bash
user=vagrant
step=

while [ $# -gt 0 ]; do
	case "$1" in
		-u)
			user=$2
			shift
			;;
		-s)
			step=$2
			shift
			;;
	esac
	shift
done

home=/home/$user

localsrc=$home/local/src
localbin=$home/local/bin
	
dotfiles=$localsrc/dotfiles
dotfiles_git=https://github.com/joaodubas/webfaction-dotfiles.git

uid=$user
gid=$user


#
# Add needed repos, install dependencies and upgrade the system
#
function upgrade_system() {
	echo "upgrade system"
	apt-get update -y --quiet
	apt-get install -y --quiet \
		dkms \
		linux-headers-generic \
		linux-headers-$(uname -r) \
		linux-image-extra-$(uname -r) \
		software-properties-common
	# ppa for vim
	add-apt-repository -y ppa:fcwu-tw/ppa
	wget -qO- https://get.docker.io/gpg | apt-key add -
	echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
	apt-get update -y --quiet

	echo "install needed deps"
	apt-get install -y --quiet \
		build-essential \
		lxc-docker \
		python-setuptools \
		python-dev \
		ruby-dev \
		vim \
		vim-nox \
		vim-scripts \
		tmux \
		git \
		make \
		cmake \
		curl \
		zsh
}


#
# Create a docker group and add it to the user
#
function docker_group() {
	echo "created docker group"
	if [ ! $(egrep -i "^docker" /etc/group) ]; then
		groupadd docker
	fi
	if [ ! $(groups $user | grep docker) ]; then
		gpasswd -a $user docker
	fi
}


#
# Configure docker daemon to expose a given port and dns
#
function docker_conf() {
	echo "configure docker daemon"

	# best way to access docker
	local sock="-H unix:///var/run/docker.sock"
	# allow access through url, used by maestro-ng
	local host="-H 127.0.0.1:2375"
	# used by skydock
	local dns="--dns 172.17.42.1"

	echo DOCKER_OPTS=\"$host $sock $dns\" > /etc/default/docker
}



#
# Create needed directories in user home
#
function make_home() {
	echo "prepare home directory"
	if [ ! -d $home/local ]; then
		mkdir -p $home/local/{bin,src}
	fi
	if [ ! -d $home/public ]; then
		mkdir -p $home/public
	fi
}


#
# Install nodejs
#
function node_install() {
	echo "install node"
	if [ -s $localsrc/nodejs ]; then
		return 0
	fi

	local version="v0.10.24"
	local dirname="node-$version-linux-x64"
	local compact="$dirname.tar.gz"
	local url="http://nodejs.org/dist/$version/$compact"

	cd $localsrc
	echo `pwd`
	echo $localsrc
	curl -O $url
	tar -xzf $compact
	ln -s $dirname nodejs
	rm $compact

	cd $localbin
	ln -s ../src/nodejs/bin/* ./
}


#
# Install go
#
function golang_install() {
	echo "install golang"
	if [ -s $localsrc/go ]; then
		return 0
	fi

	local version="1.2.1"
	local dirname="go$version.linux-amd64"
	local compact="$dirname.tar.gz"
	local url="https://go.googlecode.com/files/$compact"

	cd $localsrc
	curl -O $url
	tar -xzf $compact
	rm $compact

	cd $localbin
	ln -s ../src/go/bin/* ./

	mkdir -p $home/local/go/{src,bin,pkg}
}


#
# Change ownership to user
#
function change_owner() {
	echo "grant ownership to $user"
	cd $home
	chown --recursive $uid:$gid $home
}


#
# DOTFILES CONFIGURATION
#


#
# Initialize all submodules and install vim Bundles
#
function init_submodule() {
	echo "init dotfiles submodules"
	cd $dotfiles
	git submodule update --init --recursive
	vim +BundleInstall +qall
}


#
# Finish install of command-t
#
function prepare_command_t() {
	echo "install command_t"
	cd $dotfiles/.vim/bundle/Command-T/ruby/command-t
	ruby extconf.rb
	make
}


#
# Finish install of tern
#
function prepare_tern() {
	echo "install tern"
	cd $dotfiles/.vim/bundle/tern_for_vim
	$localbin/npm install
}


#
# Finish install of YCM
#
function prepare_ycm() {
	echo "install ycm"
	cd $dotfiles/.vim/bundle/YouCompleteMe
	bash install.sh
}


#
# Finish enabling of autoenv
#
function prepare_autoenv() {
	echo "install autoenv"
	cd $localbin
	if [ ! -L $localbin/activate.sh ]; then
		ln -s ../src/dotfiles/.autoenv/activate.sh ./
	fi
}


#
# Clone or update dotfiles
#
function clone_dotfile() {
	echo "clone dotfiles"
	if [ -d $dotfiles ]; then
		cd $dotfiles
		git fetch
		git rebase origin/master
	else
		git clone $dotfiles_git $dotfiles
	fi
	init_submodule
	prepare_command_t
	prepare_tern
	prepare_ycm
	prepare_autoenv
}


#
# Link configuration files in user home path
#
function link_to_home() {
	echo "link dotfiles into home"
	files=(".bash_aliases" ".bash_personal" ".path_env.py" ".tmux.conf" ".vimrc" ".vim" ".gitignore_global")
	for file in "${files[@]}"; do
		if [ -L $home/$file ]; then
			continue
		fi
		ln -s $dotfiles/$file $home
	done
	if [ ! -f $home/.gitconfig ]; then
		cp $dotfiles/.gitconfig $home/
	fi
}


#
# Link $dotfiles/bin into user bin dir
#
function link_to_bin() {
	echo "link dotfiles/bin into user/bin"
	local origin=$dotfiles/bin
	ln -s $origin/* $localbin
}


#
# Link needed files from dotfiles
#
function link_dotfile() {
	link_to_home
	link_to_bin
}


#
# Start dotfiles install
#
function make_conf() {
	echo "prepare dotfiles"
	clone_dotfile
	link_dotfile
}


#
# PREPARE VIRTUALENV
#


#
# Install virtualenv
#
function install_virtualenv() {
	echo "install virtualenv"
	pip install -U virtualenvwrapper virtualenv
}


#
# Install pip
#
function install_pip() {
	echo "install pip"
	easy_install pip
}


#
# Prepare python setuptools
#
function prepare_python() {
	echo "prepare python"
	install_pip
	install_virtualenv
}


#
# Install oh-my-zsh
#
function install_zsh() {
	echo "install zsh"
	export ZSH=${home}/.oh-my-zsh
	curl -L http://install.ohmyz.sh | bash
}


case $step in
	upgrade)
		upgrade_system
		;;
	group)
		docker_group
		;;
	node)
		node_install
		change_owner
		;;
	golang)
		golang_install
		change_owner
		;;
	python)
		prepare_python
		;;
	home)
		make_home
		change_owner
		;;
	dotfiles)
		make_conf
		;;
	zsh)
		upgrade_system
		install_zsh
		change_owner
		;;
	*)
		upgrade_system
		install_zsh
		prepare_python
		make_home
		docker_group
		node_install
		golang_install
		make_conf
		change_owner
		;;
esac
