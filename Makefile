PIP_COMPILE_FLAGS = -U --generate-hashes --build-isolation --allow-unsafe
PYTHON_SOURCES = src tests
PACKAGE_NAME = photo_renamer

default: check

run: 
	python src/photo_renamer/__main__.py

build:
	pyinstaller -F src/photo_renamer/__main__.py --name photo-renamer

check: mypy flake8 isort-check black-check pytest req_file

fmt: black

black:
	black $(PYTHON_SOURCES)

black-check:
	black --check --diff $(PYTHON_SOURCES)

flake8:
	flake8 $(PYTHON_SOURCES)

isort:
	isort $(PYTHON_SOURCES)

isort-check:
	isort --check --diff $(PYTHON_SOURCES)

mypy:
	mypy $(PYTHON_SOURCES)

pytest:
	pytest -vv --color=yes --durations=20 --doctest-modules tests

pytest2:
	pytest -vv --color=yes --durations=20 --doctest-modules --cov $(PACKAGE_NAME) --pyargs $(PACKAGE_NAME) tests

pytest-k kw=keyword:
	pytest -k $(kw) -vv --color=yes --durations=20 --doctest-modules --cov $(PACKAGE_NAME) --pyargs $(PACKAGE_NAME) tests

fix: black isort
	black $(PYTHON_SOURCES)
	@echo -e "\nAll fixed!"

clean:
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf .coverage
	find -type d -name '__pycache__' | xargs --no-run-if-empty rm -rf
	find -type d -name '*.egg-info' | xargs --no-run-if-empty rm -rf

cleanall: clean
	rm -rf .venv dist .eggs logs

requirements:
	@echo "# Please seat back and relax, this may take some time. :)"
	poetry update

req_file:
	poetry export -f requirements.txt --output requirements.txt

.PHONY: default fmt check black black-check flake8 mypy pytest requirements req_file run build pytest2
