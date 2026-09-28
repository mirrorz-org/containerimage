#!/bin/bash
source common.sh
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"
docker-tags debian |
while read tag; do
    echo $tag | grep -qP -- '-\d{8}' && continue
    dockerfile=$(mktemp)
    printf 'FROM debian:%s\n' "$tag" > "$dockerfile"
    cat << 'EOF' >> "$dockerfile"
RUN set -eu; \
    prefix=''; api=''; \
    if dpkg --compare-versions "$(dpkg-query -W -f='${Version}' apt)" ge 1.6; then \
        prefix='mirror+'; api='/api/apt/mirrorlist'; \
    fi; \
    for file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do \
        [ -f "$file" ] || continue; \
        sed -E -i \
            "s#https?://(deb\.debian\.org|security\.debian\.org)/(debian(-security)?)/?#${prefix}http://mirrors.cernet.edu.cn${api}/\2#g" \
            "$file"; \
    done
EOF
    # Docker Hub (disabled): -t mirrorz-org/debian:$tag
    docker buildx build --platform "$platforms" -f $dockerfile \
        -t ghcr.io/mirrorz-org/debian:$tag \
        --push .
    rm $dockerfile
done
