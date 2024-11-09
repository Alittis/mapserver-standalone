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

# Copy the mapfile configuration to the Apache web directory
# COPY mapfile.map /var/www/html/mapfile.map
COPY slovenia.map /var/www/html/slovenia.map

# Copy individual shapefile components to the target directory
# COPY data/world-administrative-boundaries.shp /var/www/html/data/world-administrative-boundaries.shp
# COPY data/world-administrative-boundaries.dbf /var/www/html/data/world-administrative-boundaries.dbf
# COPY data/world-administrative-boundaries.shx /var/www/html/data/world-administrative-boundaries.shx
COPY data/svn_rjava_1200x800.tif /var/www/html/data/svn_rjava_1200x800.tif
COPY data/natura2000.geojson /var/www/html/data/natura2000.geojson

# Configure Apache to serve MapServer requests
RUN echo "ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" >> /etc/apache2/conf-enabled/mapserver.conf
# RUN echo "Alias /map /var/www/html/mapfile.map" >> /etc/apache2/conf-enabled/mapserver.conf
RUN echo "Alias /map /var/www/html/slovenia.map" >> /etc/apache2/conf-enabled/mapserver.conf

# Expose port 80 for the HTTP server
EXPOSE 80

# Start Apache in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
