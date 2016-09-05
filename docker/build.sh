#! /bin/bash

function die {
    echo >&2 "$@"
    exit 1
}

REPO=${1:-https://github.com/clementine-player/Clementine.git}
BRANCH=${2:-master}

git clone $REPO clementine-player || die "git clone failed"
cd clementine-player/bin || die
git checkout $BRANCH || die "git checkout failed"

PKG_CONFIG_LIBDIR=/target/lib/pkgconfig \
  cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=/src/Toolchain-mingw32.cmake \
  -DQT_HEADERS_DIR=/target/include \
  -DQT_LIBRARY_DIR=/target/bin \
  -DPROTOBUF_PROTOC_EXECUTABLE=/target/bin/protoc \
  || die "cmake failed"

make || die "make failed"

cd clementine-player/dist/windows || die

ln -s /src/windows/clementine-deps/* . && \
ln -s ../../bin/clementine*.exe . && \
makensis clementine.nsi || die "makensis failed"
