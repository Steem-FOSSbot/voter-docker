# Set the base image to Ubuntu
FROM        ubuntu:trusty

# File Author / Maintainer
MAINTAINER Shaun Morrow

# Update the repository and install Redis Server
RUN         apt-get update && apt-get install -y redis-server

# Run Redis Server
ENTRYPOINT  ["/usr/bin/redis-server"]