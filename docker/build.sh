#! /bin/bash

REPO=${1:-https://github.com/clementine-player/Clementine.git}
BRANCH=${2:-master}

git clone $REPO clementine-player
cd clementine-player/bin
git checkout $BRANCH

PKG_CONFIG_LIBDIR=/target/lib/pkgconfig \
  cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=/src/Toolchain-mingw32.cmake \
  -DQT_HEADERS_DIR=/target/include \
  -DQT_LIBRARY_DIR=/target/bin \
  -DPROTOBUF_PROTOC_EXECUTABLE=/target/bin/protoc && \
  make

cd clementine-player/dist/windows

ln -s /src/windows/clementine-deps/* . && \
ln -s ../../bin/clementine*.exe . && \
makensis clementine.nsi
