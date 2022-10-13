#!/bin/bash

mode="$1"
ubuntu_version=$(lsb_release -r -s)

if [ $mode == "redn" ]; then
    if [ $ubuntu_version == "18.04" ]; then
        ofed_fid="1mRAbumsdeP_nLRECohTpcaOmZ5sID0QP"
    elif [ $ubuntu_version == "16.04" ]; then
      ofed_fid="18OQ4NemC4Xj_Fhlj3P6skvh9Du5n4Z9m"
    else
      echo "Wrong ubuntu distribution for $mode!"
      exit 0
    fi
elif [ $mode == "scalestore" ] || [ $mode == "dmc" ]; then
  if [ $ubuntu_version == "18.04" ]; then
    ofed_fid="1xfZCA5eTttiQGOFXsewlTqGKVZe7MYy_"
  elif [ $ubuntu_version == "20.04" ]; then
    ofed_fid="1yPvFSKFFTpBcc7zzTdkqf97tyG6uJ0TN"
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

pip install gdown

# download ofed from gdrive
python download_gdrive.py $ofed_fid install/ofed.tar.gz

if [ $mode == "dmc" ]; then
  pip install python-memcached
  sudo apt install libmemcached-dev -y
fi

# install ofed
cd install
if [ ! -d "./ofed" ]; then
  tar zxf ofed.tar.gz
  mv MLNX* ofed
fi
cd ofed
sudo ./mlnxofedinstall --force
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
if [ $mode == "scalestore" ] || [ $mode == "dmc" ]; then
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
if [ $mode == "scalestore" || $mode == "dmc" ]; then
  if [ ! -d "/usr/src/gtest" ]; then
    sudo apt install -y libgtest-dev
  fi
  cd /usr/src/gtest
  sudo cmake .
  sudo make
  sudo make install
fi

if [ $mode == "redn" ]; then
  echo "Please restart the machine"
fi
