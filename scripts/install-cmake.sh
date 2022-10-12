#!/bin/bash

if [ ! -f cmake-3.16.8.tar.gz ]; then
  wget https://cmake.org/files/v3.16/cmake-3.16.8.tar.gz
fi
if [ ! -d "./cmake-3.16.8" ]; then
  tar zxf cmake-3.16.8.tar.gz
  cd cmake-3.16.8 && ./configure && make -j 4 && sudo make install
fi