FROM ubuntu as builder

RUN apt update && \
    apt install -y build-essential curl git libglib2.0-dev ksh bison \
        flex libsctp-dev && \
    mkdir -p ~/opt/src &&\
    git clone https://github.com/platinumthinker/Seagull.git -b sctp --depth 1 ~/opt/src/seagull

RUN cd ~/opt/src/seagull/seagull/trunk/src && \
    curl --create-dirs -o ~/opt/src/seagull/seagull/trunk/src/external-lib-src/openssl-1.0.2e.tar.gz https://www.openssl.org/source/openssl-1.0.2e.tar.gz &&\
    echo 'BUILD_EXE_CC_FLAGS_LINUX="$BUILD_EXE_CC_FLAGS_LINUX -Wno-uninitialized"' >> ./build.conf &&\
    ksh build-ext-lib.ksh &&\
    ksh build.ksh -target all

RUN    tar czf /root/bin.tgz ~/opt/src/seagull/seagull/trunk/src/bin/* \
    && tar czf /root/exe-env.tgz ~/opt/src/seagull/seagull/trunk/src/exe-env/* \
    && tar czf /root/pkg.tgz /root/exe-env.tgz /root/bin.tgz

FROM ubuntu as distro
RUN    apt update \
    && apt install -y ksh locales libsctp1 curl\
    && apt upgrade -y \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/pkg.tgz /root/pkg.tgz
RUN    tar xzf /root/pkg.tgz -C /root --strip=1 \
    && tar xzf /root/bin.tgz -C /usr/local/bin --strip=8 \
    && mkdir -p /opt/seagull \
    && tar xzf /root/exe-env.tgz -C /opt/seagull --strip=8 \
    && mkdir -p /opt/seagull/diameter-env/logs \
    && mkdir -p /opt/seagull/h248-env/logs \
    && mkdir -p /opt/seagull/http-env/logs \
    && mkdir -p /opt/seagull/msrp-env/logs \
    && mkdir -p /opt/seagull/octcap-env/logs \
    && mkdir -p /opt/seagull/radius-env/logs \
    && mkdir -p /opt/seagull/sip-env/logs \
    && mkdir -p /opt/seagull/synchro-env/logs \
    && mkdir -p /opt/seagull/xcap-env/logs
RUN rm -f /root/*.tgz

ENV LD_LIBRARY_PATH /usr/local/bin

WORKDIR /opt/seagull
