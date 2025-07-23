# ─── build stage (always compile for amd64) ─────────────────────────
FROM golang:1.24-bookworm AS build

WORKDIR /src
COPY . .

# Ensure static, CGO-free build
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64

RUN go build -o /out/pktvizd ./cmd/pktvizd

# Needs root caps, so run as 0
USER 0
CMD ["./pktvizd"]