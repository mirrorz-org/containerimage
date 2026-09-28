#!/bin/bash
source common.sh
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"
docker-tags alpine |
while read tag; do
    dockerfile=$(mktemp)
    cat << EOF > $dockerfile
FROM alpine:$tag
RUN sed -i \
    -e 's/dl-.*.alpinelinux.org/mirrors.cernet.edu.cn/g' \
    /etc/apk/repositories
EOF
    # Docker Hub (disabled): -t mirrorz-org/alpine:$tag
    docker buildx build --platform "$platforms" -f $dockerfile \
        -t ghcr.io/mirrorz-org/alpine:$tag \
        --push .
    rm $dockerfile
done
