docker buildx build . --progress=plain --platform linux/amd64 --tag 76527413/ffmpeg:latest
docker buildx build . --progress=plain --platform linux/arm64 --tag arm64/76527413/ffmpeg:latest
