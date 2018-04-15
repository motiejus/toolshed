[![Build Status](https://travis-ci.org/motiejus/toolshed.svg?branch=master)](https://travis-ci.org/motiejus/toolshed)
[![motiejus/toolshed container status](https://images.microbadger.com/badges/image/motiejus/toolshed.svg)](https://microbadger.com/images/motiejus/toolshed "Docker image badger from microbadger.com")
[![motiejus/toolshed_disk container status](https://images.microbadger.com/badges/image/motiejus/toolshed_disk.svg)](https://microbadger.com/images/motiejus/toolshed_disk "Docker image badger from microbadger.com")

# Toolshed

Docker container with lots of tools. Builds two containers:

* [motiejus/toolshed](https://hub.docker.com/r/motiejus/toolshed/). This is
  just a docker image.
* [motiejus/toolshed_disk](https://hub.docker.com/r/motiejus/toolshed_disk/).
  This image has `/toolshed.img.xz`, which can be written to a USB stick.
  Currently quite empty, because travis-ci enforces a 50min limit on image
  builds which is problematic for xz, and ~20GB-ish of space, which is
  problematic without xz.

## Security considerations

`motiejus/toolshed` is just a bunch of packages and can be safely used as-is.

`motiejus/toolshed_disk` contains my (motiejus@) public ssh keys, sets a
guess-able username/password, and starts sshd on startup. Keep this in
mind if you want to use the image, or grep for `motiejus` in your fork.
