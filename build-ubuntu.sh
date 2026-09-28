#!/bin/bash
source common.sh
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"
docker-tags ubuntu |
while read tag; do
    echo $tag | grep -q '-' && continue
    dockerfile=$(mktemp)
    printf 'FROM ubuntu:%s\n' "$tag" > "$dockerfile"
    # Official Ubuntu DEB822 sources already separate security suites.
    # Their URIs and Suites fields are adjacent, including on ports architectures.
    cat << 'EOF' >> "$dockerfile"
RUN set -eu; \
    prefix=''; api=''; \
    if dpkg --compare-versions "$(dpkg-query -W -f='${Version}' apt)" ge 1.6; then \
        prefix='mirror+'; api='/api/apt/mirrorlist'; \
    fi; \
    for file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do \
        [ -f "$file" ] || continue; \
        sed -E -i \
            "s#https?://([a-z]+\.)?(archive\.ubuntu\.com|security\.ubuntu\.com|ports\.ubuntu\.com)/(ubuntu(-ports)?)/?#${prefix}http://mirrors.cernet.edu.cn${api}/\3#g" \
            "$file"; \
        if [ -n "$api" ]; then \
            case "$file" in \
                *.sources) \
                    sed -E -i '/^URIs: /{N; /\nSuites: [^[:space:]]+-security[[:blank:]]*$/s#(mirror[+]http://mirrors\.cernet\.edu\.cn/api/apt/mirrorlist/ubuntu(-ports)?)(\n)#\1?official_index=1\3#;}' "$file" ;; \
                *) \
                    sed -E -i '/^[[:space:]]*deb(-src)?[[:space:]]/s#(mirror[+]http://mirrors\.cernet\.edu\.cn/api/apt/mirrorlist/ubuntu(-ports)?)([[:blank:]]+[^[:space:]]+-security[[:blank:]])#\1?official_index=1\3#g' "$file" ;; \
            esac; \
        fi; \
    done
EOF
    # Docker Hub (disabled): -t mirrorz-org/ubuntu:$tag
    docker buildx build --platform "$platforms" -f $dockerfile \
        -t ghcr.io/mirrorz-org/ubuntu:$tag \
        --push .
    rm $dockerfile
done
