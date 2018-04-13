.PHONY: container lint push

SCRIPTS = $(shell awk '/\#!\/bin\/bash/ && FNR == 1 {print FILENAME}' image/*)

container: .motiejus_toolshed

lint:
	shellcheck $(SCRIPTS)

push:
	@if [ ! "$(TRAVIS_BRANCH)" = "master" ]; then \
		echo "branch $(TRAVIS_BRANCH) detected, expected master"; \
	else \
		echo "$(DOCKER_PASS)" | docker login -u motiejus --password-stdin; \
		docker push motiejus/toolshed:latest; \
	fi

.motiejus_toolshed: Dockerfile
	docker build -t motiejus/toolshed .
	touch $@

.PHONY: img start stop test

img: toolshed.img

PASSWD ?= ubuntu

toolshed.img: .tmp/.faux_container
	docker run -ti --rm --privileged \
		--name toolshed_builder \
		--env IMG_DST=/x/$@ \
		--env PASSWD=$(PASSWD) \
		-v `pwd`:/x \
		toolshed_builder /x/image/create

start: toolshed.img
	image/start $(PWD)
	@echo "See boot.log for boot status"
	@echo "Use \"ssh -p 5555 motiejus@localhost\" (passwd: $(PASSWD)) to reach it"

stop:
	kill $(shell cat qemu.pid)
	rm qemu.pid

test:
	docker run -ti --rm \
		--name toolshed_tester \
		-v `pwd`:/x \
		toolshed_builder \
		/x/image/test /x/

.tmp/.faux_container: image/Dockerfile
	docker build -t toolshed_builder image
	mkdir -p $(dir $@) && touch $@
