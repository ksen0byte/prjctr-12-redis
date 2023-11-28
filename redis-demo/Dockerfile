FROM alpine:latest

# Install Redis CLI
RUN apk add --no-cache redis bash

# Copy demo scripts into the container
COPY ./scripts /scripts

# Set the working directory
WORKDIR /scripts

# Set the entrypoint script (optional, could be bash)
ENTRYPOINT ["bash"]
