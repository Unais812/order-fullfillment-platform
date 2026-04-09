# Use the official Golang image as the base
FROM golang:1.23-alpine AS builder

# Set working directory inside the container
WORKDIR /build

# Copy go.mod and go.sum files for dependency installation
COPY go.mod go.sum ./

# Cache dependencies separately so Docker doesn't re-download them on every build
RUN go mod download 

# Copy the entire application source
COPY . .

# Build the Go binary
RUN go build -o app .

# Final lightweight stage
FROM gcr.io/distroless/static-debian12 

WORKDIR /build

COPY --from=builder /build/app /app

USER nonroot

EXPOSE 8086

CMD ["/app"]