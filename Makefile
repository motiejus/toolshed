.PHONY: container push

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
