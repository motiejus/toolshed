VSN = $(shell date +%Y%m%d)_$(shell git rev-parse --short HEAD)
LABELS = $(addprefix --label org.label-schema.,\
		 build-date=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		 vcs-url=https://github.com/motiejus/toolshed \
		 vcs-ref=$(shell git rev-parse --short HEAD) \
		 schema-version=1.0)

.PHONY: container push-container push-image
container: .tmp/container

.tmp/container:
	mkdir -p .tmp
	docker build -t motiejus/toolshed $(LABELS) .
	touch $@

ifeq ($(TRAVIS_BRANCH),master)
push-container: .tmp/container
	docker images
	echo "$(DOCKER_PASS)" | docker login -u motiejus --password-stdin;
	docker push motiejus/toolshed:latest
push-image: toolshed-$(VSN).img.lz4
	umask 077 && gpg -q -d --batch --passphrase=$(PASSPHRASE) secrets/key.asc > .tmp/key
	rsync -e "ssh -i .tmp/key -o StrictHostKeyChecking=no" -aP $< ci@vno1.jakstys.lt:
else
push-container: .tmp/container
	@echo "branch $(TRAVIS_BRANCH) detected, not pushing container"
push-image: toolshed-$(VSN).img.lz4
	@echo "branch $(TRAVIS_BRANCH) detected, not pushing image"
endif

# Below is the setup for bootable image
toolshed-$(VSN).img.lz4: .tmp/container
	mkdir -p .tmp
	ti="-i"; \
    if [[ -t 0 ]]; then ti="-ti"; fi; \
	docker run --privileged "$$ti" --rm \
		--init \
		-v $(PWD):/x \
		-w /x \
		motiejus/toolshed \
		scripts/create_img $@

toolshed.img: toolshed-$(VSN).img.lz4
	lz4 -k -d $< $@

.PHONY: start
start: toolshed.img
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
start_initrd: toolshed-$(VSN).img.lz4
	qemu-system-x86_64 \
		-m 512 \
		-nographic \
		-display curses \
		-append "console=ttyS0 init=/usr/bin/bash net.ifnames=0 biosdevname=0 nomodeset" \
		-device e1000,netdev=net0 \
		-netdev user,id=net0,hostfwd=tcp::5555-:22 \
		-kernel ".tmp/vmlinuz" \
		-initrd ".tmp/initrd.img"
