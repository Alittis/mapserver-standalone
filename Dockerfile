# Use the official MapServer Docker image as the base
FROM mapserver/mapserver:latest

# Set UTF-8 locale environment variables
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Switch to root to install dependencies and configure Apache
USER root

# Install Apache and MapServer CGI support
RUN apt-get update && apt-get install -y apache2 cgi-mapserver python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Disable MapCache by removing its configuration
RUN rm -f /etc/apache2/mods-enabled/mapcache.conf

# Enable CGI in Apache
RUN a2enmod cgi

# Install FastAPI, Uvicorn, and MapScript for Python
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install fastapi uvicorn mapscript

# Copy the mapfile configuration to the Apache web directory
COPY slovenia.map /var/www/html/slovenia.map

# Copy individual data files to the target directory
COPY data/svn_rjava_1200x800.tif /var/www/html/data/svn_rjava_1200x800.tif
COPY data/natura2000.geojson /var/www/html/data/natura2000.geojson

# Configure Apache to serve MapServer requests
RUN echo "ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/" >> /etc/apache2/conf-enabled/mapserver.conf
RUN echo "Alias /map /var/www/html/slovenia.map" >> /etc/apache2/conf-enabled/mapserver.conf

# Expose port 80 for Apache and 8000 for FastAPI
EXPOSE 80
EXPOSE 8000

# Copy FastAPI application
COPY app.py /app/app.py
WORKDIR /app

# Start both Apache and FastAPI when the container launches
CMD apachectl -D FOREGROUND & uvicorn app:app --host 0.0.0.0 --port 8000