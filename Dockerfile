##################################################
# Notes for GitHub Actions
#       * Dockerfile instructions: https://git.io/JfGwP
#       * Environment variables: https://git.io/JfGw5
##################################################

#########################
# STAGE: GLOBAL
# Description: Global args for reuse
#########################

ARG VERSION="0"

#########################
# STAGE: RUN
# Description: Run the app
#########################

FROM docker.io/alpine:latest as RUN

ARG VERSION

LABEL name="action-release-prepper" \
    maintainer="MAHDTech <MAHDTech@salt-labs.dev>" \
    vendor="Salt Labs" \
    version="${VERSION}" \
    summary="GitHub Action to prepare for shipping time" \
    url="https://github.com/salt-labs/action-release-prepper" \
    org.opencontainers.image.source="https://github.com/salt-labs/action-release-prepper"

WORKDIR /

RUN \
    apk update \
 && apk add --no-cache\
            git \
            gnupg \
            bash \
            curl \
            wget \
            zip \
            jq \
            tzdata \
 && rm -rf /var/cache/apk/*

COPY "LICENSE" "README.md" /

COPY "scripts" "/scripts"

ENV PATH /scripts/:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/bin:/sbin

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
#CMD [ "--help" ]
