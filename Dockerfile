FROM crystallang/crystal:0.26.1
WORKDIR /src/
COPY . .
RUN shards install
RUN crystal build --release --link-flags="-static" src/server.cr

FROM alpine:latest
RUN apk -U add curl jq bash python3 py3-pip &&\
    pip3 install awscli netaddr
COPY --from=0 /src/startup.sh /startup.sh
COPY --from=0 /src/server /server
COPY --from=0 /src/code_hash.txt /code_hash.txt
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f -s http://localhost:3000/health || exit 1
EXPOSE 3000
ENTRYPOINT ["bash", "/startup.sh"]
