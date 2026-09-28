#!/bin/bash
platforms="${PLATFORMS:-linux/amd64}"
dockerfile=$(mktemp)
cat << EOF > "$dockerfile"
FROM archlinux:latest
RUN printf 'Server = https://mirrors.cernet.edu.cn/archlinux/\$repo/os/\$arch\n' \
    > /etc/pacman.d/mirrorlist
EOF
# Docker Hub (disabled): -t mirrorz-org/archlinux:latest
docker buildx build --platform "$platforms" -f "$dockerfile" \
    -t ghcr.io/mirrorz-org/archlinux:latest \
    --push .
rm "$dockerfile"
