#https://github.com/ksvc/FFmpeg/wiki/hevcpush
#https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
FROM ubuntu:18.04

RUN sed -i s/archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    sed -i s/security.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    apt update -y && \
    apt install -y \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    meson \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    yasm \
    zlib1g-dev \
    nasm \
    libx264-dev \
    libx265-dev libnuma-dev \
    libvpx-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/ffmpeg_sources ~/bin && \
    cd ~/ffmpeg_sources && \
    git clone --depth=1 -b release/3.4 https://github.com/ksvc/FFmpeg.git ffmpeg

RUN cd ~/ffmpeg_sources && \
    cd ffmpeg && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm" \
    --ld="g++" \
    --bindir="$HOME/bin" \
    --enable-static --enable-pic \
    --disable-encoders --enable-encoder=aac --enable-encoder=libx264 --enable-gpl --enable-libx264 --enable-encoder=libx265 --enable-libx265 \
    --disable-decoders --enable-decoder=aac --enable-decoder=h264 --enable-decoder=hevc  \
    --disable-demuxers --enable-demuxer=aac --enable-demuxer=mov --enable-demuxer=mpegts --enable-demuxer=flv --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=hls  \
    --disable-muxers --enable-muxer=h264  --enable-muxer=flv --enable-muxer=f4v  --enable-muxer=mp4 \
    --disable-doc && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    hash -r

WORKDIR /root/bin

# CMD           ["--help"]
# ENTRYPOINT    ["ffmpeg"]