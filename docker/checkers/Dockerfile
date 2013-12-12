# python checker
#
# VERSION: see `TAG`
FROM stackbrew/ubuntu:quantal
MAINTAINER Joao Paulo Dubas "joao.dubas@gmail.com"

# Install pip
RUN apt-get -y update \
    && apt-get -y install python-setuptools wget \
    && easy_install pip

# Install node binary
ENV VERSION_NODE 0.10.22
RUN mkdir /opt/downloads \
    && cd /opt/downloads \
    && wget http://nodejs.org/dist/v$VERSION_NODE/node-v$VERSION_NODE-linux-x64.tar.gz \
    && tar -xzf node-v$VERSION_NODE-linux-x64.tar.gz \
    && ln -s node-v$VERSION_NODE-linux-x64 nodejs \
    && ln -s /opt/downloads/nodejs/bin/* /usr/local/bin

# Install checkers
ADD package.json /opt/checkers/package.json
ADD requirements.txt /opt/checkers/requirements.txt
RUN cd /opt/checkers \
    && npm install -g \
    && pip install -r requirements.txt
