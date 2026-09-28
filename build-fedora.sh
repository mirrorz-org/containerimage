#!/bin/bash
source common.sh
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"
docker-tags fedora |
while read tag; do
    dockerfile=$(mktemp)
    printf 'FROM fedora:%s\n' "$tag" > "$dockerfile"
    cat << 'EOF' >> "$dockerfile"
RUN mkdir -p /etc/dnf/repos.override.d \
    && printf '%s\n' \
        '[fedora]' \
        'mirrorlist=https://mirrors.cernet.edu.cn/api/rpm/mirrorlist/fedora/releases/$releasever/Everything/$basearch/os/' \
        'baseurl=' \
        'metalink=' \
        '[updates]' \
        'mirrorlist=https://mirrors.cernet.edu.cn/api/rpm/mirrorlist/fedora/updates/$releasever/Everything/$basearch/' \
        'baseurl=' \
        'metalink=' \
        > /etc/dnf/repos.override.d/99-cernet.repo \
    && for file in /etc/yum.repos.d/fedora-modular.repo \
        /etc/yum.repos.d/fedora-updates-modular.repo \
        /etc/yum.repos.d/fedora.repo \
        /etc/yum.repos.d/fedora-updates.repo; do \
        if [ -f "$file" ]; then \
            sed -e 's|^metalink=|#metalink=|g' \
                -e 's|^#baseurl=http://download.example/pub/fedora/linux|mirrorlist=https://mirrors.cernet.edu.cn/api/rpm/mirrorlist/fedora|g' \
                -i.bak "$file" || exit 1; \
        fi; \
    done
EOF
    # Docker Hub (disabled): -t mirrorz-org/fedora:$tag
    docker buildx build --platform "$platforms" -f "$dockerfile" \
        -t ghcr.io/mirrorz-org/fedora:$tag \
        --push .
    rm "$dockerfile"
done
