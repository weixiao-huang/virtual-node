FROM golang:1.20 as builder

RUN go install github.com/virtual-kubelet/virtual-kubelet/cmd/virtual-kubelet@v1.11.0

FROM ubuntu:22.04

RUN apt update && apt install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/bin/virtual-kubelet /usr/local/bin