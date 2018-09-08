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

Examples:

    $ toolshed man strace
    $ toolshed cargo build /x/
    $ toolshed ipython3

# A note on my public keys

Grep `motiejus` in this repo. My public keys are imported in at least 1 place.
