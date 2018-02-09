FROM crystallang/crystal:latest
WORKDIR /src/
COPY . .
RUN shards install
RUN crystal build --release --link-flags="-static" src/server.cr

FROM alpine:latest
COPY --from=0 /src/server /server
COPY --from=0 /src/code_hash.txt /code_hash.txt
EXPOSE 3000
CMD ["/server"]
