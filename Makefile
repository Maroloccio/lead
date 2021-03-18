# Please note:
#
# * Apart from the default target, keep other targets sorted lexicographically
# * Distance non-default targets among themselves by two empty lines
# * Ensure each target has a space after its identifier and before the colon

# -----------------------------------------------------------------------------

# Use Bash shell dialect
SHELL := /bin/bash

# Execute all recipe lines of all targets in a single shell invocation
.ONESHELL :

# Silence echoing of commands
.SILENT :

# Filesystem origin of this invocation
this_file := $(realpath $(firstword $(MAKEFILE_LIST)))
base_dir := $(shell dirname "$(this_file)")
dir_name := $(shell basename "$(base_dir)")

# -----------------------------------------------------------------------------

# Python virtual environment directory name
venv_dir_name := .venv

# -----------------------------------------------------------------------------


# Default target displaying list of available targets
.PHONY : default
default :
	echo Available targets:
	perl -ne 'print "- $$1\n" if /^([a-z_-]+)\s*:\s/' "$(this_file)"


# -----------------------------------------------------------------------------


# Activate Python virtual environment
.PHONY : activate_python_virtual_environment
activate_python_virtual_environment : \
		create_python_virtual_environment
	echo Activating Python virtual environment...
	cd "$(base_dir)" || exit 1
	source "$(venv_dir_name)/bin/activate"


# Build Python package distribution artifacts
.PHONY : build_python_package_distribution
build_python_package_distribution : \
		ensure_availability_of_pypa_tools
	python3 -m build


# Clean up transient and generated artifacts
.PHONY : clean
clean :
	echo Cleaning up transient and generated artifacts...
	cd '$(base_dir)' || exit 1
	rm --force --recursive --verbose \
		'$(venv_dir_name)' \
		.transient \
		build \
		dist \
		src/*.egg-info/


# Create Python virtual environment
.PHONY : create_python_virtual_environment
create_python_virtual_environment :
	echo Creating Python virtual environment...
	cd '$(base_dir)' || exit 1
	if [[ -d '$(venv_dir_name)' ]]; then
		echo Python virtual environment already present.
	else
		python3 -m venv "$(venv_dir_name)"
	fi


# Ensure up-to-date availability of Python Packaging Authority tools
.PHONY : ensure_availability_of_pypa_tools
ensure_availability_of_pypa_tools : \
		activate_python_virtual_environment
	echo Ensuring up-to-date availability of PyPA tools...
	python3 -m pip install --user --upgrade build


# Upload updated package to Python Package Index
.PHONY : upload_to_python_package_index
upload_to_python_package_index : \
		build_python_package_distribution
	echo Ensuring up-to-date availability of PyPI upload tools...
	python3 -m pip install --upgrade twine
	echo Uploading distribution package to Python Package Index...
	python3 -m twine upload dist/*
