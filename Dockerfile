FROM gophish/gophish:latest

# Switch to root to bypass Railway volume permission locks
USER root

# Copy our custom configuration
COPY gophish/config.json /opt/gophish/config.json

# Tell Railway's internal network to open BOTH these ports
EXPOSE 80
EXPOSE 3333
