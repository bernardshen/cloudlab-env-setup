#!/bin/bash

mode="$1"
ofed_fid=""

if [ $mode == "redn" ]; then
  ubuntu_version=$(lsb_release -r -s)
  if [ $ubuntu_version == "18.04" ]; then
    ofed_fid="1mRAbumsdeP_nLRECohTpcaOmZ5sID0QP"
  elif [ $ubuntu_version == "16.04" ]; then
    ofed_fid="18OQ4NemC4Xj_Fhlj3P6skvh9Du5n4Z9m"
  else
    echo "Wrong ubuntu distribution for $mode!"
    exit 0
  fi
elif [ $mode == "scalestore" ]; then
  ubuntu_version=$(lsb_release -r -s)
  if [ $ubuntu_version == "18.04" ]; then
    ofed_fid="1xfZCA5eTttiQGOFXsewlTqGKVZe7MYy_"
  else
    echo "Wrong ubuntu distribution for $mode!"
    exit 0
  fi
fi
exit 0

sudo apt update -y
# echo "jcshen:123456" | sudo chpasswd

# download python and gdown
echo "==== Downloading Gdown ===="
sudo apt install python3-pip -y

pip3 install gdown

# download ofed from gdrive
python3 download_ofed.py $ofed_fid ofed.tar.gz

# install ofed
cd install
if [ ! -d "./ofed" ]; then
  tar zxf ofed.tar.gz ofed
fi
cd ofed
sudo ./mlnxofedinstall
sudo /etc/init.d/openibd restart

# install oh my zsh
# cd ~
# if [ ! -d ".oh-my-zsh" ]; then
#   sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
# fi

# install cmake
# cd install
# wget https://cmake.org/files/v3.16/cmake-3.16.8.tar.gz
# if [ ! -d "./cmake-3.16.8" ]; then
#   tar zxf cmake-3.16.8.tar.gz
#   cd cmake-3.16.8 && ./configure && make -j 4 && sudo make install
# fi


# install gtest
# if [ ! -d "/usr/src/gtest" ]; then
#   cd /usr/src/gtest
#   sudo apt install -y libgtest-dev
#   sudo mkdir build
#   cd build && sudo cmake .. && sudo make -j 4 && sudo make install
# fi
