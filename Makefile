PYTORCH_INSTALL_DIR=$(shell pwd)/third-party/pytorch/libtorch_install_cpp20_debug

debug:
	lldb -- jank -I"${PYTORCH_INSTALL_DIR}/include" -I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" -l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib"

repl:
	jank -I"${PYTORCH_INSTALL_DIR}/include" -I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" -l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" repl

run:
	jank \
		-I"${PYTORCH_INSTALL_DIR}/include" \
		-I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" \
		-l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" \
		run src/main.jank

test:
	jank \
		-I"${PYTORCH_INSTALL_DIR}/include" \
		-I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" \
		-l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" \
		run ${TEST_FILE}

test-setup:
	jank \
		-I"${PYTORCH_INSTALL_DIR}/include" \
		-I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" \
		-l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" \
		run test/pytorch-setup.jank

.PHONY: repl run test setup-test

