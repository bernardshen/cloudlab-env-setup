#!/bin/bash

if [ ! -d "/usr/src/gtest" ]; then
  sudo apt install -y libgtest-dev
fi
cd /usr/src/gtest
sudo cmake . && sudo make -j 4 && sudo make install