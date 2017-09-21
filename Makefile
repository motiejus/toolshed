.PHONY: all

all: .motiejus_toolshed

.motiejus_toolshed: Dockerfile
	docker build -t motiejus/toolshed .
	touch $@
