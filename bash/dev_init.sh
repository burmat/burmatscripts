#!/bin/bash
apt-get -yq install nasm make
mkdir -p /opt/tools
cd /opt/tools
wget https://musl.cc/x86_64-w64-mingw32-cross.tgz
tar -xvf x86_64-w64-mingw32-cross.tgz
cd x86_64-w64-mingw32-cross/bin
export PATH=$(pwd):$PATH

cd /opt/tools
wget https://musl.cc/i686-w64-mingw32-cross.tgz
tar -xvzf i686-w64-mingw32-cross.tgz
cd i686-w64-mingw32-cross/bin
export PATH=$(pwd):$PATH