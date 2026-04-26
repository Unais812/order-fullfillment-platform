# Use the official Golang image as the base
FROM golang:1.24-alpine AS builder

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
FROM golang:1.24-alpine

WORKDIR /build

# Copy the compiled binary from the builder stage
COPY --from=builder /app /bin/app

EXPOSE 8081

# Run the application
CMD ["/bin/app"]