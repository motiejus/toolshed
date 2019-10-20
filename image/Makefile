VSN = $(shell date +%Y%m%d)_$(shell git rev-parse --short HEAD)

toolshed-$(VSN).img.lz4: .tmp/test_rsa.pub create_img
	docker run --privileged -ti --rm \
		--init \
		-v $(PWD):/x \
		-w /x \
		motiejus/toolshed \
		./create_img $< $@

.tmp/test_rsa.pub:
	mkdir -p .tmp
	ssh-keygen -f .tmp/test_rsa -t rsa -N ''
