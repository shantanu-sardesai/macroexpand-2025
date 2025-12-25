# jank @ macroexpand 2025

This repo is a reproduction of [Jianling](https://github.com/jianlingzhong)'s [implementation](https://docs.google.com/document/d/1TAmp8hB3x_kDq8MHCFnedyJ9u_HdbWJ8GgnCICLGuTI/edit?tab=t.0) of a neural net in pytorch using jank's seamless C++ interop.

## Prerequisites

Clone the project and fetch all the git submodules.

```sh
git submodule update --recursive --init && chmod +x ./bin/*.sh
```

### PyTorch

> Currently the build setup only works for MacOS.
>
> To get libtorch on other OS's you can get it directly from the [PyTorch website](https://pytorch.org/get-started/locally/) by selecting the following options:
>
> 1. PyTorch Build: Stable.
> 2. Your OS.
> 3. Package: LibTorch.
> 4. Language: C++.
> 5. Compute platform: Default (Auto-selected).
>
> And then running the command displayed on their site.
>
> NOTE: If you get libtorch from their site instead of building it locally the `Makefile` variables will need to be updated to point to the new installation.

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
make test-setup
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

## Quick links

- [Live presentation](https://www.youtube.com/live/1DKa3-vyPsw?si=Apojxu3Yc6RNgB3-&t=28943).
- [Slide deck](https://docs.google.com/presentation/d/1wsmXcY9elz67l731a0Lne10q37SiBTChc-EqQdAqvjY/edit?usp=sharing).

