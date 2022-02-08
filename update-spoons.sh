#!/usr/bin/env bash

# Delete tmp repo.
rm -rf tmp_spoons/

# Clone Spoons into  a temporary directory.
git clone https://github.com/Hammerspoon/Spoons.git tmp_spoons && \

# Apply patches.
#git -C $PWD/tmp_spoons/ apply -v ../patches/seal-pr-231.patch && \

# Clean up and copy the source files.
rm -rf Spoons/* && \
cp -R tmp_spoons/Source/* Spoons/ && \

# Delete tmp repo.
rm -rf tmp_spoons/
