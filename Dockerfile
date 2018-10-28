FROM buildpack-deps:bionic
ENV USER=root PATH="/root/.cargo/bin:${PATH}"

COPY overlay/ /
ADD https://github.com/motiejus.keys /etc/dropbear-initramfs/authorized_keys
RUN awk -F'# ' '/^deb /{n=1;next}; n==1 && /# deb-src/{print NR}; n=0' \
        /etc/apt/sources.list | \
        xargs -I{} sed -i '{}s/^# //' /etc/apt/sources.list && \
    \
    yes | env DEBIAN_FRONTEND=noninteractive unminimize && \
    \
    ln -fs /usr/share/zoneinfo/Europe/Vilnius /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        linux-image-generic syslinux pxelinux memtest86+ cryptsetup && \
    sed -i '$a CRYPTSETUP=y' /etc/cryptsetup-initramfs/conf-hook && \
    ln /boot/vmlinuz-* /var/lib/tftpboot/pxelinux/vmlinuz && \
    ln /boot/initrd.img-* /var/lib/tftpboot/pxelinux/initrd.img && \
    ln /boot/memtest86+.bin /var/lib/tftpboot/pxelinux/memtest && \
    ln /usr/lib/syslinux/modules/bios/ldlinux.c32 \
         /usr/lib/syslinux/modules/bios/vesamenu.c32 \
         /usr/lib/syslinux/modules/bios/libcom32.c32 \
         /usr/lib/syslinux/modules/bios/libutil.c32 \
         /usr/lib/PXELINUX/pxelinux.0 \
      /var/lib/tftpboot/pxelinux/


RUN curl https://sh.rustup.rs -sSf | \
        sh -s -- -y --default-toolchain nightly-x86_64-unknown-linux-gnu && \
    rustup target add x86_64-unknown-linux-musl && \
    rustup target add armv7-unknown-linux-gnueabihf && \
    cargo search --limit 0 && \
    apt-get install -y gcc-7-arm-linux-gnueabihf && \
    echo '[target.armv7-unknown-linux-gnueabihf]' > ~/.cargo/config && \
    echo 'linker = "arm-linux-gnueabihf-gcc-7"' >> ~/.cargo/config


RUN DEBIAN_FRONTEND=noninteractive apt-get install \
                    -o Dpkg::Options::="--force-confdef" -y \
    lsof parallel debootstrap tmux apt-file nmap busybox mlocate iproute2 tree \
    vim man-db strace sudo socat redir htop jq tsocks rsync dropbear-initramfs \
    openssh-server git pv elinks kpartx fakechroot python-all dnsmasq graphviz \
    fakeroot python3-all python-doc python3-doc postgresql-client nginx-extras \
    build-essential cloc git-svn awscli bash-completion erlang erlang-doc lshw \
    erlang-manpages python-virtualenv dnsutils telnet xinetd graphicsmagick mc \
    iotop pandoc texlive manpages-dev manpages glibc-doc autossh valgrind lvm2 \
    cppreference-doc-en-html ruby-dev python-pygments binutils-doc pypy nodejs \
    sox libsox-fmt-all lua5.2 lua5.2-doc python3-sphinx python3-flake8 doxygen \
    pastebinit clang clang-6.0-doc iputils-ping debhelper pigz supervisor flex \
    rubber golang ipython autotools-dev nftables debian-archive-keyring screen \
    gdb-doc netcat-openbsd sloccount stl-manual dh-systemd python-dev pbuilder \
    bsdgames gdb ddd ddd-doc rkt ghc-doc ghc cabal-install redir zsh nginx-doc \
    libsystemd-dev psmisc pypy-dev info ipython3 youtube-dl python3-matplotlib \
    cowsay gcc-doc doc-rfc parted python-pip gdebi aptitude mysql-client mdadm \
    musl-tools units qpdf sqlite xmlto grub2 python3-yaml pgcli lynx iodine bc \
    mencoder cmake git-buildpackage zip unzip mtr python3-pandas python3-scipy \
    upx-ucl jupyter inkscape pax moreutils biber && \
    \
    apt-file update && \
    \
    updatedb
