FROM ubuntu:18.04
ARG packages
RUN awk -F'# ' '/^deb /{n=1;next}; n==1 && /# deb-src/{print NR}; n=0' \
        /etc/apt/sources.list | \
        xargs -I{} sed -i '{}s/^# //' /etc/apt/sources.list
RUN yes | env DEBIAN_FRONTEND=noninteractive unminimize
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
                    $(echo "$packages" | tr , ' ')
RUN ln -fs /usr/share/zoneinfo/Europe/Vilnius /etc/localtime && \
    dpkg-reconfigure tzdata && \
    apt-file update && updatedb
