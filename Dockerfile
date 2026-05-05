FROM gophish/gophish:latest

# Copy our custom configuration
COPY gophish/config.json /opt/gophish/config.json

# Expose Admin and Phishing ports
EXPOSE 3333
EXPOSE 80
