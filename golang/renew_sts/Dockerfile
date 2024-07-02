# Use an official Golang runtime as a parent image
FROM golang:1.23rc1-alpine3.20 AS build

# Set the working directory inside the container
WORKDIR /go/src/app

# Copy the local package files to the container's workspace
COPY . .

# Download necessary Go modules
RUN go mod download

# Build the Go binary for Linux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/bin/renew_sts

# Start a new stage from scratch
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=build /go/src/app/renew_sts .

# Run the executable
CMD ["./renew_sts"]

