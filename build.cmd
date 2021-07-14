docker build --progress=plain -t 76527413/ffmpeg:amd64 .
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker build --progress=plain -f Dockerfile.arm64 -t 76527413/ffmpeg:arm64 .
