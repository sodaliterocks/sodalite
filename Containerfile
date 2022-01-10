FROM fedora:latest

WORKDIR /sodalite
COPY . .

ENV VARIANT=sodalite

RUN dnf install -y rpm-ostree selinux-policy selinux-policy-targeted policycoreutils

RUN mkdir -p /sodalite/build/cache
RUN mkdir -p /sodalite/build/repo

RUN ostree --repo="/sodalite/build/repo" init --mode=archive

RUN rpm-ostree compose tree \
    --unified-core \
    --cachedir="/sodalite/build/cache" \
    --repo="/sodalite/build/repo" \
    /sodalite/src/fedora-sodalite.yaml
