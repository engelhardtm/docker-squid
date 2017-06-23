FROM alpine:3.6

EXPOSE 3128

VOLUME ["/var/cache/squid/"]

RUN apk -U --no-cache add squid ca-certificates libressl

COPY squid.conf /etc/squid/squid.conf

ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
