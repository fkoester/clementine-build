# Based on https://github.com/clementine-player/Clementine/wiki/Compiling-from-Source-(Windows)
FROM ubuntu

RUN apt-get update && apt-get install debootstrap schroot
RUN debootstrap --variant=buildd --arch i386 precise /var/chroot/mingw http://archive.ubuntu.com/ubuntu/
RUN cp /etc/{passwd,shadow,group,sudoers} /var/chroot/mingw/etc/
RUN sh -c "echo /proc /var/chroot/mingw/proc none rbind 0 0 >> /etc/fstab"
RUN sh -c "echo mingw > /var/chroot/mingw/etc/debian_chroot"
RUN mount /var/chroot/mingw/proc
RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe restricted multiverse" >> /var/chroot/mingw/etc/apt/sources.list
RUN echo '[mingw]\n\
description=MinGW build environment\n\
directory=/var/chroot/mingw\n
groups=chroot\n
personality=linux32\n'\
>> /etc/schroot/schroot.conf

RUN schroot -c mingw
RUN apt-get update && apt-get install yasm cmake qt4-dev-tools stow unzip autoconf libtool \
    bison flex pkg-config gettext libglib2.0-dev intltool wine git-core \
    sudo texinfo wget

RUN wget http://old-releases.ubuntu.com/ubuntu/pool/main/libt/libtool/libtool_2.2.6b-2ubuntu1_i386.deb && \
    dpkg -i libtool_2.2.6b-2ubuntu1_i386.deb

RUN cd /

RUN mkdir mingw
RUN cd mingw
RUN tar -xvf mingw-w32-bin_i686-linux_20130523.tar.bz2
RUN chmod +rx /root
RUN export PATH=$PATH:/mingw/bin

RUN mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
RUN echo ':DOSWin:M::MZ::/usr/bin/wine:' > /proc/sys/fs/binfmt_misc/register

RUN mkdir /usr/i586-mingw32msvc && \
    ln -s /usr/i586-mingw32msvc /target && \
    mkdir /src /target/stow /target/bin
RUN git clone https://github.com/clementine-player/Dependencies.git /src
ADD zlib-1.2.8.tar.gz /src/downloads/
RUN cd /src/windows && make

RUN git clone https://github.com/fkoester/Clementine.git clementine-player
RUN cd clementine-player/bin
RUN git checkout inhibit-suspend-while-playing
RUN PKG_CONFIG_LIBDIR=/target/lib/pkgconfig \
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=/src/Toolchain-mingw32.cmake \
    -DQT_HEADERS_DIR=/target/include \
    -DQT_LIBRARY_DIR=/target/bin \
    -DPROTOBUF_PROTOC_EXECUTABLE=/target/bin/protoc
RUN make
