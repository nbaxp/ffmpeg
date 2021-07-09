#https://github.com/ksvc/FFmpeg/wiki/hevcpush
#https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
FROM gcc:9.4.0-buster

RUN apt update -qq

RUN apt install -y \
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
    zlib1g-dev

RUN apt install -y --fix-missing nasm
RUN mkdir -p ~/ffmpeg_sources ~/bin

WORKDIR /root/ffmpeg_sources

RUN git clone --depth=1 -b release/3.4 https://github.com/ksvc/FFmpeg.git ffmpeg

RUN apt install -y --fix-missing libx265-dev libnuma-dev libvpx-dev libmp3lame-dev libopus-dev

RUN cd ~/ffmpeg_sources && \
    git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
    cd x264 && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic && \
    PATH="$HOME/bin:$PATH" make && \
    make install

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
    --disable-encoders --enable-encoder=aac --enable-encoder=libx264 --enable-gpl --enable-libx264 --enable-encoder=libx265  --enable-libx265 \
    --disable-decoders --enable-decoder=aac --enable-decoder=h264 --enable-decoder=hevc  \
    --disable-demuxers --enable-demuxer=aac --enable-demuxer=mov --enable-demuxer=mpegts --enable-demuxer=flv --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=hls  \
    --disable-muxers --enable-muxer=h264  --enable-muxer=flv --enable-muxer=f4v  --enable-muxer=mp4 \
    --disable-doc && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    hash -r

