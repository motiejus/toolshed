.PHONY: container lint push

SCRIPTS = $(shell awk '/\#!\/bin\/bash/ && FNR == 1 {print FILENAME}' image/*)

container: .motiejus_toolshed

lint:
	shellcheck $(SCRIPTS)

push:
	docker images
	@if [ ! "$(TRAVIS_BRANCH)" = "master" ]; then \
		echo "branch $(TRAVIS_BRANCH) detected, expected master"; \
	else \
		echo "$(DOCKER_PASS)" | docker login -u motiejus --password-stdin; \
		docker push $(IMAGE):latest; \
	fi

.motiejus_toolshed: Dockerfile
	docker build -t motiejus/toolshed \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` .
	touch $@

################################################################################
# Writable disk image below
################################################################################

.PHONY: img start stop test

img: toolshed.img.xz

PASSWD ?= ubuntu
toolshed.img.xz: .tmp/.faux_builder
	docker run -ti --rm --privileged \
		--name toolshed_builder \
		--env IMG_DST=/x/$@ \
		--env PASSWD=$(PASSWD) \
		-v `pwd`:/x \
		motiejus/toolshed_builder /x/image/create

deployable: .tmp/.faux_deploy

start: toolshed.img
	image/start $(PWD)
	@echo "See boot.log for boot status"
	@echo "Use \"ssh -p 5555 motiejus@localhost\" (passwd: $(PASSWD)) to reach it"

toolshed.img: toolshed.img.xz
	pv -n --timer --bytes $< | xz -cd > $@

stop:
	kill $(shell cat qemu.pid)
	rm qemu.pid

test: toolshed.img
	docker run -ti --rm \
		--name toolshed_tester \
		-v `pwd`:/x \
		motiejus/toolshed_builder \
		/x/image/test /x/

.tmp/.faux_builder: image/Dockerfile.build
	docker build -t motiejus/toolshed_builder -f image/Dockerfile.build image
	mkdir -p $(dir $@) && touch $@

.tmp/.faux_deploy: toolshed.img.xz image/Dockerfile.deploy
	docker build -t motiejus/toolshed_disk \
		-f image/Dockerfile.deploy \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg VCS_REF=`git rev-parse --short HEAD` .
	mkdir -p $(dir $@) && touch $@
