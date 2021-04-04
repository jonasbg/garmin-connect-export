FROM python:3.9.2-alpine3.12

ENV USERNAME=
ENV PASSWORD=
ENV TZ=Europe/Oslo
ENV VERSION=${VERSION}
ENV GITHUB_REF=${GITHUB_REF}
ENV BUILD_DATE=${BUILD_DATE}

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

################### SUPERCRONIC ###########################
RUN if [ "$TARGETPLATFORM" == "linux/amd64" ] ;\
    then \
        export SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64; \
        export SUPERCRONIC=supercronic-linux-amd64; \
        export SUPERCRONIC_SHA1SUM=048b95b48b708983effb2e5c935a1ef8483d9e3e; \
    elif [ "$TARGETPLATFORM" == "linux/arm64" ] ;\
    then \
        export SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-arm; \
        export SUPERCRONIC=supercronic-linux-arm; \
        export SUPERCRONIC_SHA1SUM=d72d3d40065c0188b3f1a0e38fe6fecaa098aad5; \
    fi \
    && apk add --no-cache curl tzdata\
    && curl -fsSLO "${SUPERCRONIC_URL}" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "${SUPERCRONIC}" \
    && mv "${SUPERCRONIC}" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic
################### SUPERCRONIC ###########################
WORKDIR /app

RUN echo '@daily python /app/gcexport.py -u --username $USERNAME --password $PASSWORD --count all --directory /data --subdir {YYYY}' > cron-job \
    && chmod u+x cron-job

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN mkdir /data && chmod 777 /data
RUN mkdir /var/log/garmin  && chmod 777 /var/log/garmin
USER appuser

COPY . .

CMD ["supercronic", "cron-job"]