#!/bin/sh

apt update -y
DEBIAN_FRONTEND="noninteractive" apt install ninja-build libgtk-3-dev \
	libgtkmm-3.0-dev libpulse-dev libogg-dev libvorbis-dev python3-pip \
	python3-setuptools $COMPILER_PKG git cmake pkg-config valac -y
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

git clone https://github.com/SCOTT-HAMILTON/CFakeLib
cd CFakeLib
mkdir build
meson build
ninja -C build
ninja -C build install
cd ..

git clone https://github.com/SCOTT-HAMILTON/CFakeMicWavPlayer
cd CFakeMicWavPlayer
mkdir build
meson build
ninja -C build
ninja -C build install
cd ..
git clone https://github.com/SCOTT-HAMILTON/ControlsForFake-gtk
cd ControlsForFake-gtk
mkdir build
meson build
ninja -C build
