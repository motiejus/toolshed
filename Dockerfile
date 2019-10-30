FROM buildpack-deps:disco

RUN sed -i '/^deb/ N; s/# deb-src/deb-src/' /etc/apt/sources.list && \
    \
    yes | env DEBIAN_FRONTEND=noninteractive unminimize && \
    \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
    jupyter inkscape pax biber python3-sphinxcontrib.spelling python3-nbsphinx \
    gnupg2 stow upx-ucl python-pandas-doc cython3 cowbuilder wait-for-it ctags \
    gpgv2 moreutils pdftk-java propellor libsox-dev unrar less openvpn latexmk \
    texlive-lang-european dos2unix postgis postgresql-11-pgrouting postgis-gui \
    pgformatter software-properties-common shellcheck protobuf-compiler tzdata \
    spatialite-bin cloud-guest-utils qemu-system-x86 libsqlite3-mod-spatialite \
    cdebootstrap postgis-doc cdebootstrap-static docker.io linux-image-generic \
    syslinux pxelinux udev cryptsetup entr lz4 binwalk gdal-bin ethtool hdparm \
    pktools hdparm memtest86+ sdparm ntp ntpdate geotiff-bin && \
    \
    systemctl disable \
        NetworkManager.service \
        apparmor.service \
        apt-daily-upgrade.timer apt-daily.timer \
        avahi-daemon.service avahi-daemon.socket \
        containerd.service \
        dnsmasq.service \
        epmd.service epmd.socket \
        nginx.service \
        openvpn.service \
        postgresql.service \
        snapd.socket \
        supervisor.service \
        ubuntu-fan.service \
        unattended-upgrades.service \
        xinetd.service && \
    \
    curl -L recs.pl > /usr/local/bin/recs && chmod a+x /usr/local/bin/recs && \
    curl -o /etc/dropbear-initramfs/authorized_keys \
        https://github.com/motiejus.keys && \
    \
    git clone --recursive \
        https://github.com/motiejus/dotfiles \
        /root/.dotfiles && \
    stow -d /root/.dotfiles ctags tmux vim && \
    \
    apt-file update

COPY overlay/ /

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    \
    sed -i '$a CRYPTSETUP=y' /etc/cryptsetup-initramfs/conf-hook && \
    ln /boot/vmlinuz-* /var/lib/tftpboot/pxelinux/vmlinuz && \
    ln /boot/initrd.img-* /var/lib/tftpboot/pxelinux/initrd.img && \
    ln /boot/memtest86+.bin /var/lib/tftpboot/pxelinux/memtest && \
    ln /usr/lib/syslinux/modules/bios/ldlinux.c32 \
         /usr/lib/syslinux/modules/bios/vesamenu.c32 \
         /usr/lib/syslinux/modules/bios/libcom32.c32 \
         /usr/lib/syslinux/modules/bios/libutil.c32 \
         /usr/lib/PXELINUX/pxelinux.0 \
      /var/lib/tftpboot/pxelinux/ && \
    update-initramfs -v -k all -u && \
    \
    updatedb
