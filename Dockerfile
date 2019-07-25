FROM nginx:stable-alpine
WORKDIR /app

RUN apk add openssl

COPY startup.sh /usr/local/bin/
RUN ln -s usr/local/bin/startup.sh / # backwards compat

ENTRYPOINT ["startup.sh"]