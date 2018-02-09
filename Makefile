.PHONY: all push

all: .motiejus_toolshed

.motiejus_toolshed: Dockerfile
	docker build -t motiejus/toolshed .
	touch $@

push:
	@if [ ! "$(TRAVIS_BRANCH)" = "master" ]; then \
		echo "branch $(TRAVIS_BRANCH) detected, expected master"; \
		exit; \
	fi
	@echo "$(DOCKER_PASS)" | docker login -u motiejus --password-stdin
	docker push motiejus/toolshed:latest
