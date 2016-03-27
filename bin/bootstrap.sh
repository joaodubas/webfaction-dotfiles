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
	apt-get -y -qq --force-yes update
	apt-get -y -qq --force-yes install \
		dkms \
		linux-headers-generic \
		linux-headers-$(uname -r) \
		software-properties-common

	echo "enable oracle java repo"
	add-apt-repository -y ppa:webupd8team/java

	echo "install needed deps"
	apt-get -y -qq --force-yes update
	apt-get -y -qq --force-yes install \
		build-essential \
		xz-utils \
		locales \
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
		zsh \
		oracle-java8-installer

	locales_install
}


#
# Add locales
#
function locales_install() {
	echo "Install locales"
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen

	locale-gen --purge --lang en_US
	locale-gen --purge --lang pt_BR
	locale-gen
}


#
# Install docker and pals
#
function docker_compose() {
	echo "install docker compose"

	local version="1.6.2"
	local arch="$(uname -s)-$(uname -m)"
	local cmd="docker-compose-${machine}"
	local base="https://github.com/docker/compose/releases/download" 
	local url="${base}/${version}/${cmd}"

	cd $localsrc
	curl -O ${url} > /dev/null
	chmod 755 ${cmd}

	cd $localbin
	ln -s ../src/${cmd} ./docker-compose
}

function docker_machine() {
	echo "install docker compose"

	local version="0.6.0"
	local arch="$(uname -s)-$(uname -m)"
	local cmd="docker-machine-${machine}"
	local base="https://github.com/docker/machine/releases/download" 
	local url="${base}/${version}/${cmd}"

	cd $localsrc
	curl -O ${url} > /dev/null
	chmod 755 ${cmd}

	cd $localbin
	ln -s ../src/${cmd} ./docker-machine
}


function docker_engine() {
	echo "Install docker"

	apt-get -y -qq --force-yes update
	apt-get -y -qq --force-yes install \
		linux-image-extra-$(uname -r) \
		apparmor \
		apt-transport-https \
		ca-certificates

	apt-key adv \
		--keyserver hkp://p80.pool.sks-keyservers.net:80 \
		--recv-keys 58118E89F3A912897C070ADBF76221572C52609D

	echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" \
		> /etc/apt/sources.list.d/docker.list

	apt-get -y -qq --force-yes update
	apt-get -y -qq --force-yes install \
		docker-engine
}

function docker() {
	echo "Install docker & pals"
	docker_engine
	docker_compose
	docker_machine
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
	local host="-H 0.0.0.0:2375"
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

	local version="v5.9.1"
	local dirname="node-$version-linux-x64"
	local compact="$dirname.tar.xz"
	local url="https://nodejs/dist/$version/$compact"

	cd $localsrc
	echo `pwd`
	echo $localsrc
	curl -O $url > /dev/null
	tar -xJf $compact > /dev/null
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

	local version="1.6"
	local dirname="go$version.linux-amd64"
	local compact="$dirname.tar.gz"
	local url="https://storage.googleapis.com/golang/$compact"

	cd $localsrc
	curl -O $url > /dev/null
	tar -xzf $compact > /dev/null
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
# Start dotfiles install
#
function make_conf() {
	echo "prepare dotfiles"
	clone_dotfile
	link_dotfile
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

	echo "init dotfiles submodules"
	cd $dotfiles
	git submodule update --init --recursive >/dev/null
	printf "y" | vim +BundleInstall +qall

	echo "install command_t"
	cd $dotfiles/.vim/bundle/Command-T/ruby/command-t
	ruby extconf.rb > /dev/null
	make > /dev/null

	echo "install tern"
	cd $dotfiles/.vim/bundle/tern_for_vim
	$localbin/npm install > /dev/null

	echo "install ycm"
	cd $dotfiles/.vim/bundle/YouCompleteMe
	bash install.sh > /dev/null
}


#
# Link needed files from dotfiles
#
function link_dotfile() {
	echo "link dotfiles into home"
	files=(".bash_aliases" ".bash_personal" ".tmux.conf" ".vimrc" ".vim" ".gitignore_global")
	for file in "${files[@]}"; do
		if [ -L $home/$file ]; then
			continue
		fi
		ln -s $dotfiles/$file $home
	done
	if [ ! -f $home/.gitconfig ]; then
		cp $dotfiles/.gitconfig $home/
	fi

	echo "link dotfiles/bin into user/bin"
	local origin=$dotfiles/bin
	ln -s $origin/* $localbin
}


#
# PREPARE VIRTUALENV
#


#
# Prepare python setuptools
#
function prepare_python() {
	echo "prepare python"

	echo "install pip"
	easy_install pip

	echo "install virtualenv"
	pip install -U virtualenvwrapper virtualenv
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
		docker
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
		prepare_python
		make_home
		docker
		docker_group
		node_install
		golang_install
		make_conf
		change_owner
		;;
esac
