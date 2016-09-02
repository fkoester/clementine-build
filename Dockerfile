# Based on https://github.com/clementine-player/Clementine/wiki/Compiling-from-Source-(Windows)

# TODO Test building on 64 bit system
FROM ubuntu32:xenial

RUN apt-get update && apt-get install -y yasm cmake qt4-dev-tools stow unzip autoconf libtool \
    bison flex pkg-config gettext libglib2.0-dev intltool wine git-core \
    sudo texinfo wget bzip2 xz-utils make nsis g++

# TODO Why not use mingw from Ubuntu packages?
RUN mkdir /mingw && \
    cd /mingw && \
    wget -q -O mingw-w32-bin_i686-linux_20130523.tar.bz2 \
    http://downloads.sourceforge.net/project/mingw-w64/Toolchains%20targetting%20Win32/Automated%20Builds/mingw-w32-bin_i686-linux_20130523.tar.bz2?use_mirror=netcologne && \
    tar -xvf mingw-w32-bin_i686-linux_20130523.tar.bz2

ENV PATH $PATH:/mingw/bin

RUN mkdir /usr/i586-mingw32msvc && \
    ln -s /usr/i586-mingw32msvc /target && \
    mkdir /src /target/stow /target/bin
RUN git clone https://github.com/clementine-player/Dependencies.git /src
RUN cd /src/downloads/ && \
    git checkout 98856df268348efb87ac8de4542d432db6a37f4d && \
    wget -q http://pkgs.fedoraproject.org/lookaside/pkgs/mingw-zlib/zlib-1.2.8.tar.gz/44d667c142d7cda120332623eab69f40/zlib-1.2.8.tar.gz

WORKDIR /src/windows

RUN make

VOLUME /output
COPY docker/build.sh /usr/local/bin/build.sh
CMD /usr/local/bin/build.sh
