# jank @ macroexpand 2025

This repo is a reproduction of [Jianling](https://github.com/jianlingzhong)'s [implementation](https://docs.google.com/document/d/1TAmp8hB3x_kDq8MHCFnedyJ9u_HdbWJ8GgnCICLGuTI/edit?tab=t.0) of a neural net in pytorch using jank's seamless C++ interop.

## Prerequisites

Clone the project and fetch all the git submodules.

```sh
git submodule update --recursive --init && chmod +x ./bin/*.sh
```

### PyTorch

Setup pytorch by running the following commands:

```sh
cd third-party/pytorch
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
python3 -m pip install -r requirements-build.txt

# The python venv needs to be active and the root of the project needs to be the current working directory.
cd ../..
./bin/install_libtorch.sh
```

Download the sample data for training from [here](https://drive.google.com/drive/folders/1Tu7XNQrYTapgX1IWK9x8gYTk_jtVzlFn?usp=sharing) and place it in the [data](./data) folder.

#### Test the setup

```sh
make setup-test
```

## C++ Interop

### Run with interop

```sh
make run
```

### Debug interop

```sh
make repl
```

