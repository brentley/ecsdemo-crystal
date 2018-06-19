FROM crystallang/crystal:0.24.2
WORKDIR /src/
COPY . .
RUN shards install
RUN crystal build --release --link-flags="-static" src/server.cr

FROM alpine:latest
RUN apk -U add curl
COPY --from=0 /src/server /server
COPY --from=0 /src/code_hash.txt /code_hash.txt
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f -s http://localhost:3000/health || exit 1
EXPOSE 3000
CMD ["/server"]
