#!/bin/sh

apt update -y
DEBIAN_FRONTEND="noninteractive" apt install ninja-build libgtk-3-dev \
	libgtkmm-3.0-dev libpulse-dev libogg-dev libvorbis-dev python3-pip \
	python3-setuptools g++-9 git cmake pkg-config -y
python3 -m pip install meson
git clone https://github.com/SCOTT-HAMILTON/FakeLib
cd FakeLib
mkdir build
meson build
ninja -C build
ninja -C build install
cd ..
git clone https://github.com/p-ranav/argparse
cd argparse
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DARGPARSE_BUILD_TESTS=OFF ..
cd ..
ninja -C build
ninja -C build install
cd ..
git clone https://github.com/SCOTT-HAMILTON/FakeMicWavPlayer
cd FakeMicWavPlayer
mkdir build
meson build
ninja -C build
ninja -C build install
cd ..
mkdir build
meson build
ninja -C build
