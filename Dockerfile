FROM ubuntu

RUN apt update &&\
  apt -y install curl vim g++ make libc-dev perl binutils git libglib2.0-dev ksh bison flex &&\
  mkdir -p ~/opt/src &&\
  git clone https://github.com/codeghar/Seagull.git ~/opt/src/seagull &&\
  cd ~/opt/src/seagull &&\
  git branch build master &&\
  git checkout build &&\
  cd ~/opt/src/seagull/seagull/trunk/src &&\
  curl --create-dirs -o ~/opt/src/seagull/seagull/trunk/src/external-lib-src/sctplib-1.0.15.tar.gz http://www.sctp.de/download/sctplib-1.0.15.tar.gz &&\
  curl --create-dirs -o ~/opt/src/seagull/seagull/trunk/src/external-lib-src/socketapi-2.2.8.tar.gz http://www.sctp.de/download/socketapi-2.2.8.tar.gz &&\
  curl --create-dirs -o ~/opt/src/seagull/seagull/trunk/src/external-lib-src/openssl-1.0.2e.tar.gz https://www.openssl.org/source/openssl-1.0.2e.tar.gz &&\
  echo 'BUILD_EXE_CC_FLAGS_LINUX="$BUILD_EXE_CC_FLAGS_LINUX -Wno-uninitialized"' >> ./build.conf &&\
  ksh build.ksh -target clean &&\
  ksh build-ext-lib.ksh &&\
  ksh build.ksh -target all &&\
  cd ~/opt/src/seagull/seagull/trunk/src &&\
  ksh ./install.ksh &&\
  cp ~/opt/src/seagull/seagull/trunk/src/ext-*/lib/lib* /usr/local/bin/ &&\
  apt -y purge curl git libc-dev perl g++ bison flex &&\
  apt-get -y --purge autoremove && \
  rm -rf ~/opt /var/lib/apt/lists/* /var/log/*
RUN [ "/bin/bash", "-c", "mkdir -p /opt/seagull/{diameter-env,h248-env,http-env,msrp-env,octcap-env,radius-env,sip-env,synchro-env,xcap-env}/logs" ]
ENV LD_LIBRARY_PATH /usr/local/bin

WORKDIR /opt/seagull
