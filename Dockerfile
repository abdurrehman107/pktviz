# ---------- build stage ------------------------------------------------
FROM --platform=linux/amd64 golang:1.24-bookworm AS build
WORKDIR /src

# Copy go.mod/go.sum first for caching
COPY go.* ./
RUN go mod download

# Copy source and build static amd64 binary
COPY . .
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -o /out/pktvizd ./cmd/pktvizd

# -------- runtime stage ---------------------------------------------
FROM gcr.io/distroless/static:latest
COPY --from=build /out/pktvizd /usr/bin/pktvizd

# You can omit USER; :latest defaults to root.
ENTRYPOINT ["/usr/bin/pktvizd"]