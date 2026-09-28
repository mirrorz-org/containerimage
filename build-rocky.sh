#!/bin/bash
source common.sh
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"
docker-tags rockylinux/rockylinux |
while read tag; do
    dockerfile=$(mktemp)
    printf 'FROM rockylinux/rockylinux:%s\n' "$tag" > "$dockerfile"
    cat << 'EOF' >> "$dockerfile"
RUN set -eu; \
    for file in /etc/yum.repos.d/Rocky-*.repo /etc/yum.repos.d/rocky*.repo; do \
        [ -f "$file" ] || continue; \
        sed -i \
            -e '/^mirrorlist=/d' \
            -e 's|^#baseurl=https\?://dl\.rockylinux\.org/$contentdir|mirrorlist=https://mirrors.cernet.edu.cn/api/rpm/mirrorlist/rocky|' \
            "$file"; \
    done
EOF
    # Docker Hub (disabled): -t mirrorz-org/rocky:$tag
    docker buildx build --platform "$platforms" -f $dockerfile \
        -t ghcr.io/mirrorz-org/rocky:$tag \
        --push .
    rm $dockerfile
done
