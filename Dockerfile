# Use the official MapServer Docker image as the base
FROM mapserver/mapserver:latest

# Switch to root to install dependencies and configure Apache
USER root

# Install Apache and MapServer CGI support
RUN apt-get update && apt-get install -y apache2 cgi-mapserver && rm -rf /var/lib/apt/lists/*

# Disable MapCache by removing its configuration
RUN rm -f /etc/apache2/mods-enabled/mapcache.conf

# Enable CGI in Apache
RUN a2enmod cgi

# Copy the mapfile configuration and data
COPY mapfile.map /var/www/html/mapfile.map
COPY data /var/www/html/data  # Copy the entire data directory with shapefileagain

# Configure Apache to serve MapServer requests
RUN echo "ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" >> /etc/apache2/conf-enabled/mapserver.conf
RUN echo "Alias /map /var/www/html/mapfile.map" >> /etc/apache2/conf-enabled/mapserver.conf

# Expose port 80 for the HTTP server
EXPOSE 80

# Start Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
