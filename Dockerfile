FROM ubuntu as builder

RUN apt update &&\
  apt -y install vim libsctp-dev curl g++ make libc-dev perl binutils git libglib2.0-dev ksh bison flex &&\
  mkdir -p ~/opt/src &&\
  git clone https://github.com/platinumthinker/Seagull.git ~/opt/src/seagull &&\
COPY Seagull /root/opt/src/seagull
RUN cd ~/opt/src/seagull &&\
  git checkout native_sctp &&\
  cd ~/opt/src/seagull/seagull/trunk/src &&\
  curl --create-dirs -o ~/opt/src/seagull/seagull/trunk/src/external-lib-src/openssl-1.0.2e.tar.gz https://www.openssl.org/source/openssl-1.0.2e.tar.gz &&\
  echo 'BUILD_EXE_CC_FLAGS_LINUX="$BUILD_EXE_CC_FLAGS_LINUX -Wno-uninitialized"' >> ./build.conf &&\
  ksh build.ksh -target clean &&\
  ksh build-ext-lib.ksh &&\
  ksh build.ksh -target all &&\
  cd ~/opt/src/seagull/seagull/trunk/src &&\
  ksh ./install.ksh &&\
  cp ~/opt/src/seagull/seagull/trunk/src/ext-*/lib/lib* /usr/local/bin/ &&\
  apt -y purge git libc-dev perl g++ bison flex libglib2.0-dev &&\
  apt-get -y --purge autoremove && \
  apt -y install libglib2.0-0 && \
  rm -rf ~/opt /var/lib/apt/lists/* /var/log/*
RUN [ "/bin/bash", "-c", "mkdir -p /opt/seagull/{diameter-env,h248-env,http-env,msrp-env,octcap-env,radius-env,sip-env,synchro-env,xcap-env}/logs" ]
COPY conf /opt/seagull/conf
ENV LD_LIBRARY_PATH /usr/local/bin

WORKDIR /opt/seagull
