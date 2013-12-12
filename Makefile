ROOT = $(CURDIR)

install_docker:
	@cd $(ROOT)/docker/checkers \
		&& docker build -t `cat REPOSITORY`:`cat TAG` . \
		&& docker tag `cat REPOSITORY`:`cat TAG` `cat REPOSITORY`:latest

install: install_docker
