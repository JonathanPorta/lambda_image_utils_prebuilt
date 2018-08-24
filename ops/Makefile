include ops/common.mk

TMP=$(shell pwd)/tmp
BATS_INSTALL=$(shell pwd)/tmp/bats
BATS=${BATS_INSTALL}/bin/bats
BATS_LIBS=${TMP}

REPO_SLUG=$(shell cat ./package.json | jq -er .repository)
VERSION=$(shell cat ./package.json | jq -er .version)

link_ops:
	@echo "Place a symlink from ./ops to ./ so that we can use the ops scripts in this project as if it were any dang project. =)"
	ln -s $(shell pwd) ./ops

test: install_bats
	BATS_LIBS=${BATS_LIBS} ${BATS} *.test.bats

clean:
	-rm -rf ${TMP}
	-rm *.rpm

package: clean
	BUILD_NUM='local' ./ops/package.sh ./package.json

release: package
	./ops/gh.sh upload ${REPO_SLUG} ${VERSION} ./*.rpm

unrelease:
	./ops/gh.sh delete ${REPO_SLUG} ${VERSION}

install: package
	sudo dnf install -y ./*rpm

uninstall:
	sudo dnf remove -y ops
