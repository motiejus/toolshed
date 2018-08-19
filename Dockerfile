FROM ubuntu:18.04
ARG PACKAGES
ARG BUILD_DATE
ARG VCS_REF

RUN awk -F'# ' '/^deb /{n=1;next}; n==1 && /# deb-src/{print NR}; n=0' \
        /etc/apt/sources.list | \
        xargs -I{} sed -i '{}s/^# //' /etc/apt/sources.list
RUN yes | env DEBIAN_FRONTEND=noninteractive unminimize
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
                    $(echo "$PACKAGES" | tr , ' ')

ENV PATH="/root/.cargo/bin:${PATH}"
ENV USER=root
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
        rustup toolchain install nightly && \
        rustup target add x86_64-unknown-linux-musl && \
        rustup target add armv7-unknown-linux-gnueabihf && \
        apt-get install -y gcc-7-arm-linux-gnueabihf && \
        echo '[target.armv7-unknown-linux-gnueabihf]' > ~/.cargo/config && \
        echo 'linker = "arm-linux-gnueabihf-gcc-7"' >> ~/.cargo/config

RUN ln -fs /usr/share/zoneinfo/Europe/Vilnius /etc/localtime && \
    dpkg-reconfigure tzdata && \
    apt-file update && updatedb

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="toolshed" \
      org.label-schema.description="ad-hoc command-line tools" \
      org.label-schema.url="https://github.com/motiejus/toolshed" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/motiejus/toolshed" \
      org.label-schema.vendor="motiejus" \
      org.label-schema.schema-version="1.0"
