VSN = $(shell date +%F)_$(shell git rev-parse --short HEAD)

toolshed-$(VSN).img.gz: .tmp/toolshed.tar .tmp/test_rsa.pub create_img
	docker run --privileged -ti --rm \
		--init \
		-v $(PWD):/x \
		-w /x \
		motiejus/toolshed \
		./create_img $< $@

.tmp/toolshed.tar:
	mkdir -p .tmp
	docker rm tmp_toolshed || :
	docker run --name tmp_toolshed motiejus/toolshed /bin/true
	docker export tmp_toolshed -o $@
	docker rm tmp_toolshed

.tmp/test_rsa.pub:
	mkdir -p .tmp
	ssh-keygen -f .tmp/test_rsa -t rsa -N ''
