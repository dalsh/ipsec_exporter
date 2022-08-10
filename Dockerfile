# Builder container.
FROM golang:1.15.15-alpine3.14 AS builder

COPY . /go/src/github.com/dalsh/ipsec_exporter
WORKDIR /go/src/github.com/dalsh/ipsec_exporter

RUN adduser -D -u 10001 scratchuser

RUN apk --no-cache add git

ENV CGO_ENABLED=0
ENV GO111MODULE="on"

RUN go build --ldflags '-extldflags "-static"' -o build/ipsec_exporter github.com/dalsh/ipsec_exporter

# Artifact container.
FROM alpine:3.14

# Install the strongswan package for the ipsec command that our exporter uses.
RUN apk --no-cache add strongswan

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /go/src/github.com/dalsh/ipsec_exporter/build/ipsec_exporter /ipsec_exporter

USER scratchuser

CMD ["/ipsec_exporter"]
