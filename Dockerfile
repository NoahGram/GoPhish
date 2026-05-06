FROM gophish/gophish:latest

# Switch to root to bypass Railway volume permission locks
USER root

# Copy our custom configuration
COPY gophish/config.json /opt/gophish/config.json

# You only need to EXPOSE the single port that Railway supports 
EXPOSE 8080
