FROM python:3.9.1-alpine3.12

ENV USERNAME=
ENV PASSWORD=
ENV TZ=Europe/Oslo

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN mkdir /data && chmod 777 /data
RUN mkdir /var/log/garmin  && chmod 777 /var/log/garmin

WORKDIR /app
COPY . .
RUN chmod +x garmin-connect && mv garmin-connect /etc/periodic/daily/

USER appuser

CMD [ "crond -f -l 8" ]