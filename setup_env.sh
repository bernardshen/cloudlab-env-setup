#!/bin/bash

sudo apt update -y
# echo "jcshen:123456" | sudo chpasswd

# download python and gdown
echo "==== Downloading Gdown ===="
sudo apt install python3-pip -y
# sudo apt-get install libnuma-dev
# sudo apt-get install libmemcached-dev zlib1g-dev
# sudo apt-get install numactl
# sudo apt-get install memcached
# sudo apt-get install hugead

pip3 install gdown

# download ofed from gdrive
echo "==== Download OFED ===="
if [ ! -d "./install/ofed.tar.gz" ]; then
  mkdir install
  cat > download_ofed.py <<- EOF
import gdown
url = 'https://drive.google.com/uc?id=1xfZCA5eTttiQGOFXsewlTqGKVZe7MYy_&export=download'
output = './install/ofed.tar.gz'
gdown.download(url, output, quiet=False)
EOF
  python3 download_ofed.py
fi

# install ofed
cd install
if [ ! -d "./MLNX_OFED_LINUX-4.9-3.1.5.0-ubuntu18.04-x86_64" ]; then
  tar zxf ofed.tar.gz
fi
cd MLNX_OFED_LINUX-4.9-3.1.5.0-ubuntu18.04-x86_64
sudo ./mlnxofedinstall
sudo /etc/init.d/openibd restart

# install oh my zsh
# cd ~
# if [ ! -d ".oh-my-zsh" ]; then
#   sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
# fi

# install cmake
cd install
wget https://cmake.org/files/v3.16/cmake-3.16.8.tar.gz
if [ ! -d "./cmake-3.16.8" ]; then
  tar zxf cmake-3.16.8.tar.gz
  cd cmake-3.16.8 && ./configure && make -j 4 && sudo make install
fi


# install gtest
if [ ! -d "/usr/src/gtest" ]; then
  cd /usr/src/gtest
  sudo apt install -y libgtest-dev
  sudo mkdir build
  cd build && sudo cmake .. && sudo make -j 4 && sudo make install
fi