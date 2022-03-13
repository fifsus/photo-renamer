# About
This app is inteded to be built as standalone *.exe app for which it utilizes PyInstaller

# Development

Install [Poetry](https://python-poetry.org/).

Install [Make](https://stackoverflow.com/questions/32127524/how-to-install-and-use-make-in-windows).

```bash
choco install make
```

Go to app root directory in your console.

Install virtual environment:

```bash
poetry install
```

Activate virtual environment:

```
cd .venv/Scripts
. activate
cd ../..
```

Run app with `Make`:
```bash
make run
```

Run app without `Make`:
```bash
photo-renamer
```

Run tests:
```bash
make pytest
```

# Distribution

Build single executable app:
```bash
make build
```

# Other
## Installation of PyInstaller
This is not required, already part of the code. Keeping it just for my own sake.

Install PyInstaller from PyPI:

pip install pyinstaller

`poetry add pyinstaller`

Go to your program’s directory and run:

pyinstaller -F src/photo_renamer/__main__.py

This will generate the bundle in a subdirectory called dist.

pyinstaller -F yourprogram.py
Adding -F (or --onefile) parameter will pack everything into single "exe".

pyinstaller -F --paths=<your_path>\Lib\site-packages  yourprogram.py
running into "ImportError" you might consider side-packages.

 pip install pynput==1.6.8
still runing in Import-Erorr - try to downgrade pyinstaller - see Getting error when using pynput with pyinstaller

For a more detailed walkthrough, see the [manual](https://pyinstaller.readthedocs.io/en/stable/).