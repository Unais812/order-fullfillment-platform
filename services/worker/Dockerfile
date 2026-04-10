# Use the official Golang image as the base
FROM golang:1.23-alpine AS builder

# Set working directory inside the container
WORKDIR /build

# Copy go.mod and go.sum files for dependency installation
COPY go.mod ./

# Cache dependencies separately so Docker doesn't re-download them on every build
RUN go mod download 

# Copy the entire application source
COPY . .

# Build the Go binary
RUN go build -o /app .

# Final lightweight stage
FROM gcr.io/distroless/static-debian12 

# Copy the compiled binary from the builder stage
COPY --from=builder /app /bin/app

# Distroless image already has a user baked in 
USER nonroot 

# this app doesnt have a port, this is the health check port
EXPOSE 8090

# Run the application
CMD ["/bin/app"]