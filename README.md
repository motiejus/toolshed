[![Build Status](https://travis-ci.org/motiejus/toolshed.svg?branch=master)](https://travis-ci.org/motiejus/toolshed)
[![motiejus/toolshed container status](https://images.microbadger.com/badges/image/motiejus/toolshed.svg)](https://microbadger.com/images/motiejus/toolshed "Docker image badger from microbadger.com")

# Toolshed

[motiejus/toolshed](https://hub.docker.com/r/motiejus/toolshed/) is a docker
image with many command-line tools.

# Usage

Setup:

    $ grep -A3 toolshed ~/.profile
    toolshed() {
        docker run --name toolshed -v `pwd`:/x -ti --rm motiejus/toolshed "$@"
    }

The above will execute the toolshed with `/x/` mounted as the current directory.

## A few examples

Rust: statically compile amd64 executable (not even depending on glibc):

    $ toolshed cargo build --target x86_64-unknown-linux-musl \
        --manifest-path=/x/Cargo.toml

Rust: compile for raspberry pi:

    $ toolshed cargo build --target armv7-unknown-linux-gnueabihf \
        --manifest-path=/x/Cargo.toml

View man pages normally not found, say, on osx:

    $ toolshed man strace systemd.unit

Things you may not have in your environment:

    $ toolshed erl

In which package does some random file live?

    $ toolshed apt-file search arm-linux-gnueabihf-gcc-7

Inspect an executable in a seemingly disposable environment:

    $ ldd /x/what_is_this

Compile LaTeX to pdf:

    $ pdflatex /x/foo.tex

# Notes

* Toolshed contains a reasonable netboot environment. Network setup is an
  exercise to the reader.
* Grep `motiejus` in this repo. My public keys are imported in at least 1
  place.
