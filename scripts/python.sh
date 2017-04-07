#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


echo
print_step 'Python'
print_info "Installing global packages..."


#
# Update pip
#
pip3 install -U pip

#
# Install Python global packages
#
packages="
    flake8
    flake8-mypy
"
for package in $packages
do
    pip3 install -U $package
done
