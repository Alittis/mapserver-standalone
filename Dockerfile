# Use the official MapServer Docker image
FROM mapserver/mapserver:latest

# Copy any custom MapServer configuration files (if any) into the container
# In this example, we’ll add a basic mapfile
COPY mapfile.map /etc/mapserver/mapfile.map

# Expose the MapServer HTTP service on port 80
EXPOSE 80

# Run MapServer in FastCGI mode for HTTP requests
CMD ["mapserv", "-nh", "/etc/mapserver/mapfile.map"]
