FROM ubuntu:16.04

MAINTAINER Motiejus Jakštys <desired.mta@gmail.com>

RUN apt-get update && apt-get install -y \
    python3 python python-doc python3-doc mc curl build-essential cloc git-svn \
    awscli bash-completion erlang erlang-doc erlang-manpages python-virtualenv \
    dnsutils lsof parallel debootstrap telnet xinetd graphicsmagick iotop tmux \
    gdb gdb-doc netcat-openbsd python-dev sloccount stl-manual c-cpp-reference \
    pandoc texlive manpages-dev manpages glibc-doc autossh valgrind pastebinit \
    cppreference-doc-en-html apt-file ruby-dev nmap busybox xmlto wget mlocate \
    python-pygments nodejs npm tsocks sox libsox-fmt-all lua5.2 lua5.2-doc vim \
    pdftk ipython-notebook ipython3-notebook cmake python-sphinx screen cowsay \
    python3-sphinx python-flake8 python3-flake8 man-db zsh clang clang-3.8-doc \
    iputils-ping strace doxygen debhelper cargo rustc rust-doc pigz supervisor \
    dh-systemd ddd ddd-doc ghc ghc-doc funny-manpages git gcc gcc-doc bsdgames \
    sudo pypy pypy-dev socat rubber zip unzip redir htop mtr golang jq ipython \
    tree dnsmasq supervisor-doc autotools-dev

RUN curl -L https://recs.pl > /usr/local/bin/recs && chmod +x /usr/local/bin/recs

RUN apt-file update && updatedb
