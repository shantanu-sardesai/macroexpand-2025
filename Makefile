PYTORCH_INSTALL_DIR=$(shell pwd)/third-party/pytorch/libtorch_install_cpp20_debug
PYTORCH_FLAGS=-I"${PYTORCH_INSTALL_DIR}/include" -I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" -l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib"

debug:
	lldb -- jank ${PYTORCH_FLAGS}

repl:
	jank ${PYTORCH_FLAGS} repl

run:
	jank ${PYTORCH_FLAGS} run src/main.jank

test:
	jank ${PYTORCH_FLAGS} run ${TEST_FILE}

test-setup:
	jank ${PYTORCH_FLAGS} run test/pytorch-setup.jank

.PHONY: repl run test test-setup

