# jank @ macroexpand

This repo is a reproduction of [Jianling](https://github.com/jianlingzhong)'s [implementation](https://docs.google.com/document/d/1TAmp8hB3x_kDq8MHCFnedyJ9u_HdbWJ8GgnCICLGuTI/edit?tab=t.0) of a neural net in pytorch using jank's seamless C++ interop.

### Installation

```sh
git submodule update --recursive --init
chmod +x ./bin/*.sh
./bin/install_libtorch.sh
```

### Run

```sh
jank \
    -I"$(pwd)/third-party/pytorch/libtorch_install_cpp20_debug/include" \
    -I"$(pwd)/third-party/pytorch/libtorch_install_cpp20_debug/include/torch/csrc/api/include" \
    -L"$(pwd)/third-party/pytorch/libtorch_install_cpp20_debug/lib" \
    run main.jank
```

