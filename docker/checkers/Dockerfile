# python checker
#
# VERSION: see `TAG`
FROM stackbrew/ubuntu:quantal
MAINTAINER Joao Paulo Dubas "joao.dubas@gmail.com"

RUN apt-get -y update \
    && apt-get -y install python-setuptools \
    && easy_install pip \
    && pip install pylint pyflakes flake8 pep8
