ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk upgrade
RUN apk add --update \
    curl \
    libcurl \
    jq

# Copy data for add-on
COPY cloudflare_dns_update.sh /cloudflare_dns_update.sh
COPY run.sh /run.sh

RUN chmod a+x /cloudflare_dns_update.sh
RUN chmod a+x /run.sh


CMD [ "/run.sh" ]
