FROM gophish/gophish:latest

# Copy our custom configuration
COPY gophish/config.json /opt/gophish/config.json

# You only need to EXPOSE the single port that Railway supports 
EXPOSE 8080

CMD ["./gophish"]
