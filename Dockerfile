#https://github.com/ksvc/FFmpeg/wiki/hevcpush
#https://github.com/runner365/ffmpeg_rtmp_h265
#https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
ARG BUILD_IMAGE=ubuntu:18.04
ARG IMAGE=ubuntu:18.04
FROM $BUILD_IMAGE as build
ARG BRANCH=release/4.1
ARG COMPILE_PACKAGES="autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev libgnutls28-dev libtool libvorbis-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev nasm checkinstall"
COPY ffmpeg/libavformat  /ffmpeg/libavformat
RUN sed -i s/archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    sed -i s/security.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    apt update -y && \
    apt install -y $COMPILE_PACKAGES && \
    apt install -y \
    libx264-dev \
    libx265-dev libnuma-dev \
    libfdk-aac-dev && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ~/ffmpeg_sources ~/bin && \
    cd ~/ffmpeg_sources && \
    git clone --depth=1 -b $BRANCH https://github.com/FFmpeg/FFmpeg.git ffmpeg && \
    /bin/cp -rf /ffmpeg/libavformat/*  /root/ffmpeg_sources/ffmpeg/libavformat && \
    rm -rf /ffmpeg/libavformat &&\
    cd ~/ffmpeg_sources && \
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
    --disable-encoders --enable-encoder=aac --enable-encoder=libx264 --enable-gpl --enable-libx264 --enable-encoder=libx265 --enable-libx265  --enable-libfreetype \
    --disable-decoders --enable-decoder=aac --enable-decoder=h264 --enable-decoder=hevc  \
    --disable-demuxers --enable-demuxer=aac --enable-demuxer=mov --enable-demuxer=mpegts --enable-demuxer=flv --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=hls  \
    --disable-muxers --enable-muxer=h264  --enable-muxer=flv --enable-muxer=f4v  --enable-muxer=mp4 \
    --disable-doc && \
    PATH="$HOME/bin:$PATH" make && checkinstall && hash -r && \
    mv ~/bin/ffmpeg /usr/local/bin && \
    rm -rf ~/ffmpeg_build ~/ffmpeg_sources ~/bin/{ffmpeg,ffprobe,ffplay,x264,x265,nasm} && \
    apt purge -y $COMPILE_PACKAGES nasm checkinstall &&  apt clean && apt autoclean

FROM $IMAGE

LABEL org.opencontainers.image.authors="76527413@qq.com"

COPY --from=build /usr/local/bin/ffmpeg /usr/local/bin

RUN sed -i s/archive.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    sed -i s/security.ubuntu.com/mirrors.ustc.edu.cn/g /etc/apt/sources.list && \
    apt update -y && \
    apt install -y \
    libx264-dev \
    libx265-dev libnuma-dev \
    libfdk-aac-dev && \
    rm -rf /var/lib/apt/lists/* && \
    echo "/usr/local/lib" > /etc/ld.so.conf.d/libc.conf
