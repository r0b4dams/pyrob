.PHONY: dev venv lint format typecheck test build install uninstall version clean testpypi testpypi_install release

APP_NAME := pyrob
VERSION := $(shell python3 -c "from src import $(APP_NAME); print($(APP_NAME).__version__)")

VENV := .venv
PY := $(VENV)/bin/python3
PIP := $(PY) -m pip

dev: venv
	@echo "\n$(APP_NAME) $(VERSION)"
	@echo "$(VENV) created. Run the following command to activate:"
	@echo "source $(VENV)/bin/activate" 

venv:
	@python3 -m venv $(VENV)
	@$(PIP) install --upgrade pip build black mypy pylint pytest pytest-mock
	@chmod +x $(VENV)/bin/activate

lint: .venv
	@$(PY) -m pylint src --ignore-paths src/pyrob/__template__

format: .venv
	@$(PY) -m black src

typecheck: .venv
	@$(PY) -m mypy src

test: .venv
	@$(PY) -m pytest tests -v

build: clean venv
	@$(PY) -m build

install: build
	@python3 -m pip install dist/$(APP_NAME)-$(VERSION).tar.gz

uninstall:
	@python3 -m pip uninstall -y $(APP_NAME)

clean:
	@scripts/clear_tags
	@find . \
	\( -name .venv \
	-o -name dist \
	-o -name __pycache__ \
	-o -name "*.mypy_cache" \
	-o -name "*.pytest_cache" \
	-o -name "*.egg-info" \
	\) -exec rm -rf {} +

# Note: add #HOME/.pypirc to skip auth prompt
# https://packaging.python.org/en/latest/guides/using-testpypi/#setting-up-testpypi-in-pypirc
# A deployment to testpypi can also be triggered manually from the GitHub repo actions tab
testpypi: build
	@$(PIP) install --upgrade twine
	@twine check dist/*
	@twine upload -r testpypi dist/*
	@twine upload dist/*

testpypi_install: .venv
	@pip install -i https://test.pypi.org/simple/ $(APP_NAME)

release:
	@chmod +x scripts/release
	@scripts/release