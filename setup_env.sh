#!/bin/bash

mode="$1"

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
echo $mode $ubuntu_version $ofed_fid

sudo apt update -y

# install anaconda
if [ ! -d "./install" ]; then
mkdir install
fi
cd install
if [ ! -f "./anaconda-install.sh" ]; then
  wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh -O anaconda-install.sh
fi
if [ ! -d "$HOME/anaconda3" ]; then
  chmod +x anaconda-install.sh
  ./anaconda-install.sh -b
  export PATH=$PATH:$HOME/anaconda3/bin
  # add conda to path
  echo PATH=$PATH:$HOME/anaconda3/bin >> $HOME/.bashrc
  conda init
  source ~/.bashrc
  # activate base
fi
conda activate base
cd ..

# download python and gdown
# echo "==== Downloading Gdown ===="
# sudo apt install python3-pip -y

pip install gdown

# download ofed from gdrive
python download_gdrive.py $ofed_fid install/ofed.tar.gz

# install ofed
cd install
if [ ! -d "./ofed" ]; then
  tar zxf ofed.tar.gz
  mv MLNX* ofed
fi
cd ofed
sudo ./mlnxofedinstall
if [ $mode == "scalestore" ]; then
  sudo /etc/init.d/openibd restart
fi
cd ..

# install oh my zsh
# cd ~
# if [ ! -d ".oh-my-zsh" ]; then
#   sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
# fi


# install cmake
if [ $mode == "scalestore" ]; then
  cd install
  if [ ! -f cmake-3.16.8.tar.gz ]; then
    wget https://cmake.org/files/v3.16/cmake-3.16.8.tar.gz
  fi
  if [ ! -d "./cmake-3.16.8" ]; then
    tar zxf cmake-3.16.8.tar.gz
    cd cmake-3.16.8 && ./configure && make -j 4 && sudo make install
  fi
  cd ..
fi


# install gtest
if [ $mode == "scalestore" ]; then
  if [ ! -d "/usr/src/gtest" ]; then
    cd /usr/src/gtest
    sudo apt install -y libgtest-dev
    sudo mkdir build
    cd build && sudo cmake .. && sudo make -j 4 && sudo make install
  fi
fi

if [ $mode == "redn" ]; then
  echo "Please restart the machine"
fi
