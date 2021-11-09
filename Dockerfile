# Production Docker build
FROM ryanprior/lutrine-dice-crystal:1.2-dev-alpine AS build
WORKDIR /opt/server
COPY ./server ./
RUN shards build --release --static

FROM scratch
COPY --from=build /opt/server/bin/server ./server
COPY ./client/dist/ ./public/
ENTRYPOINT ["./server"]
