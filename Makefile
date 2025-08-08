PYTORCH_INSTALL_DIR=$(shell pwd)/third-party/pytorch/libtorch_install_cpp20_debug

repl:
	jank \
		-I"${PYTORCH_INSTALL_DIR}/include" \
		-I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" \
		-l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" \
		repl

run:
	jank \
		-I"${PYTORCH_INSTALL_DIR}/include" \
		-I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" \
		-l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" \
		run src/main.jank

setup-test:
	jank \
		-I"${PYTORCH_INSTALL_DIR}/include" \
		-I"${PYTORCH_INSTALL_DIR}/include/torch/csrc/api/include" \
		-l"${PYTORCH_INSTALL_DIR}/lib/libtorch.dylib" \
		run test/pytorch-setup.jank

.PHONY: repl run setup-test

