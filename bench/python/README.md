### Run

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install torch torchvision
python neural-net.py # on the first run the MNIST dataset is downloaded, after that the `download` property to `false`.
```

