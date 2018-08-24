BATS_INSTALL=$(shell pwd)/tmp/bats
BATS=${BATS_INSTALL}/bin/bats
BATS_LIBS=${TMP}

install_bats: clean
	-mkdir -p ${TMP}
	-mkdir -p ${BATS_INSTALL}
	git clone https://github.com/bats-core/bats-core.git ${TMP}/bats-repo
	git clone https://github.com/ztombol/bats-support ${BATS_LIBS}/bats-support
	git clone https://github.com/ztombol/bats-assert ${BATS_LIBS}/bats-assert
	${TMP}/bats-repo/install.sh ${BATS_INSTALL}
