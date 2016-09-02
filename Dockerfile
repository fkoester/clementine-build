# Based on https://github.com/clementine-player/Clementine/wiki/Compiling-from-Source-(Windows)
# TODO Test more current Ubuntu releases
# TODO Test building on 64 bit system
FROM daald/ubuntu32:precise

RUN apt-get update && apt-get install -y yasm cmake qt4-dev-tools stow unzip autoconf libtool \
    bison flex pkg-config gettext libglib2.0-dev intltool wine git-core \
    sudo texinfo wget bzip2 make nsis g++

# TODO Is that really needed?
RUN wget -q http://old-releases.ubuntu.com/ubuntu/pool/main/libt/libtool/libtool_2.2.6b-2ubuntu1_i386.deb && \
    dpkg -i libtool_2.2.6b-2ubuntu1_i386.deb

# TODO Why not use mingw from Ubuntu packages?
RUN mkdir /mingw && \
    cd /mingw && \
    wget -q -O mingw-w32-bin_i686-linux_20130523.tar.bz2 \
    http://downloads.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win32/Automated%20Builds/mingw-w32-bin_i686-linux_20130523.tar.bz2?use_mirror=netcologne && \
    tar -xvf mingw-w32-bin_i686-linux_20130523.tar.bz2

ENV PATH $PATH:/mingw/bin

# TODO Why make everything in /root executable??
RUN chmod +rx /root

RUN mkdir /usr/i586-mingw32msvc && \
    ln -s /usr/i586-mingw32msvc /target && \
    mkdir /src /target/stow /target/bin
RUN git clone https://github.com/clementine-player/Dependencies.git /src
RUN cd /src/downloads/ && \
    wget -q http://pkgs.fedoraproject.org/lookaside/pkgs/mingw-zlib/zlib-1.2.8.tar.gz/44d667c142d7cda120332623eab69f40/zlib-1.2.8.tar.gz

WORKDIR /src/windows

RUN make

ARG REPO=https://github.com/clementine-player/Clementine.git
ARG BRANCH=master

RUN git clone $REPO clementine-player && \
    cd clementine-player/bin && \
    git checkout $BRANCH && \
    PKG_CONFIG_LIBDIR=/target/lib/pkgconfig \
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=/src/Toolchain-mingw32.cmake \
    -DQT_HEADERS_DIR=/target/include \
    -DQT_LIBRARY_DIR=/target/bin \
    -DPROTOBUF_PROTOC_EXECUTABLE=/target/bin/protoc && \
    make

RUN cd clementine-player/dist/windows && \
    ln -s /src/windows/clementine-deps/* . && \
    ln -s ../../bin/clementine*.exe . && \
    makensis clementine.nsi
