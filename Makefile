.PHONY: container push

VSN = $(shell date +%Y%m%d)_$(shell git rev-parse --short HEAD)
LABELS = $(addprefix --label org.label-schema.,\
		 build-date=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		 vcs-url=https://github.com/motiejus/toolshed \
		 vcs-ref=$(shell git rev-parse --short HEAD) \
		 schema-version=1.0)

container:
	docker build -t motiejus/toolshed $(LABELS) .
	touch $@

push:
	docker images
	@if [ ! "$(TRAVIS_BRANCH)" = "master" ]; then \
		echo "branch $(TRAVIS_BRANCH) detected, expected master"; \
	else \
		echo "$(DOCKER_PASS)" | docker login -u motiejus --password-stdin; \
		docker push motiejus/toolshed:latest; \
	fi

# Below is the setup for bootable image
toolshed.img: toolshed-$(VSN).img.lz4
	lz4 -k -d $< $@

toolshed-$(VSN).img.lz4:
	mkdir -p .tmp
	docker run --privileged -ti --rm \
		--init \
		-v $(PWD):/x \
		-w /x \
		motiejus/toolshed \
		scripts/create_img $@

.PHONY: start
start:
	qemu-system-x86_64 \
		-m 512 \
		-nographic \
		-display curses \
		-append "root=/dev/disk/by-label/toolshed rw console=ttyS0 net.ifnames=0 biosdevname=0 nomodeset" \
		-device e1000,netdev=net0 \
		-netdev user,id=net0,hostfwd=tcp::5555-:22 \
		-kernel ".tmp/vmlinuz" \
		-initrd ".tmp/initrd.img" \
		-hda "toolshed.img"

.PHONY: start_initrd
start_initrd:
	qemu-system-x86_64 \
		-m 512 \
		-nographic \
		-display curses \
		-append "init=/bin/sh console=ttyS0 net.ifnames=0 biosdevname=0 nomodeset" \
		-device e1000,netdev=net0 \
		-netdev user,id=net0,hostfwd=tcp::5555-:22 \
		-kernel ".tmp/vmlinuz" \
		-initrd ".tmp/initrd.img"
