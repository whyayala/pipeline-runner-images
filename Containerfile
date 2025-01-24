FROM quay.io/containers/buildah:v1.37.3 AS buildah

LABEL runner-executor=docker
LABEL description="A simple docker image for gitlab runner use"

RUN set -x \
      && echo -e "\e[93m==> Adding runtime dependencies...\e[39m" \
      && dnf install --assumeyes make \
              zip \
              bash \
              jq \
              python3-pip \
              groff \
      \
      && dnf -y update krb5-libs \
              python3-libs \
              python3 \
              pam-libs \
              pam \
      && echo -e "\e[93m==> Udpating pip...\e[39m" \
      && pip3 install --upgrade --no-cache-dir pip \
      \
      && echo -e "\e[93m==> Installing awscli...\e[39m" \
      && pip3 install --no-cache-dir awscli \
      && dnf clean all

FROM buildah AS buildah-rootless

RUN touch /etc/subgid /etc/subuid \
    && chmod g=u /etc/subgid /etc/subuid /etc/passwd \
    && echo build:10000:65536 > /etc/subuid \
    && echo build:10000:65536 > /etc/subgid

# Use chroot since the default runc does not work when running rootless
RUN echo "export BUILDAH_ISOLATION=chroot" >> /home/build/.bashrc

# Use VFS since fuse does not work
RUN mkdir -p /home/build/.config/containers \
&& (echo '[storage]';echo 'driver = "vfs"') > /home/build/.config/containers/storage.conf \
&& (echo 'runroot = "/tmp/containers-user-$(id -u)"') >> /home/build/.config/containers/storage.conf \
&& (echo 'graphroot = "/builds/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME/.buildah-cache"') >> /home/build/.config/containers/storage.conf

# The buildah container will run as `build` user
USER build

# Verify desired tools are working
RUN buildah -v \
    && aws --version \
    jq --version

WORKDIR /home/build