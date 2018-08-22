FROM ubuntu:18.04
ENV USER=root PATH="/root/.cargo/bin:${PATH}"

RUN awk -F'# ' '/^deb /{n=1;next}; n==1 && /# deb-src/{print NR}; n=0' \
        /etc/apt/sources.list | \
        xargs -I{} sed -i '{}s/^# //' /etc/apt/sources.list
RUN yes | env DEBIAN_FRONTEND=noninteractive unminimize
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lsof parallel debootstrap tmux apt-file nmap busybox wget mlocate tsocks \
    vim man-db strace sudo  socat redir htop jq tree dnsmasq lshw iproute2 \
    openssh-server tzdata git bc rsync pv elinks kpartx iodine fakechroot \
    fakeroot python3-all python-all python-doc python3-doc mc curl \
    build-essential cloc git-svn awscli bash-completion erlang erlang-doc \
    erlang-manpages python-virtualenv dnsutils telnet xinetd graphicsmagick \
    iotop pandoc texlive manpages-dev manpages glibc-doc autossh valgrind \
    pastebinit cppreference-doc-en-html ruby-dev xmlto python-pygments nodejs \
    sox libsox-fmt-all lua5.2 lua5.2-doc python3-sphinx python3-flake8 zsh \
    clang clang-6.0-doc iputils-ping doxygen debhelper pigz supervisor pypy \
    pypy-dev rubber zip unzip redir mtr golang ipython autotools-dev nftables \
    info gdb-doc netcat-openbsd python-dev sloccount stl-manual dh-systemd \
    bsdgames debian-archive-keyring gdb ddd ddd-doc rkt ghc-doc ghc \
    libsystemd-dev parted pbuilder psmisc binutils-doc doc-rfc cmake screen \
    cowsay flex gcc gcc-doc grub2 python-pip gdebi aptitude python3-matplotlib \
    mencoder sqlite units graphviz nginx-doc nginx-extras qpdf lynx ipython3 \
    python3-yaml mysql-client postgresql-client pgcli youtube-dl mdadm lvm2 \
    dropbear-initramfs cryptsetup

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    rustup toolchain install nightly && \
    rustup target add x86_64-unknown-linux-musl && \
    rustup target add armv7-unknown-linux-gnueabihf && \
    apt-get install -y gcc-7-arm-linux-gnueabihf && \
    echo '[target.armv7-unknown-linux-gnueabihf]' > ~/.cargo/config && \
    echo 'linker = "arm-linux-gnueabihf-gcc-7"' >> ~/.cargo/config

ADD https://github.com/motiejus.keys /etc/dropbear-initramfs/authorized_keys
COPY overlay/etc/initramfs-tools/hooks/extras /etc/initramfs-tools/hooks/extras

RUN sed -i '$a CRYPTSETUP=y' /etc/cryptsetup-initramfs/conf-hook

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    linux-image-generic

RUN ln -fs /usr/share/zoneinfo/Europe/Vilnius /etc/localtime && \
    dpkg-reconfigure tzdata && \
    apt-file update && updatedb
