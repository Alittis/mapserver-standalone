# Use the official MapServer Docker image as the base
FROM mapserver/mapserver:latest

# Set UTF-8 locale environment variables
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Switch to root to install dependencies and configure Apache
USER root

# Install Apache, MapServer CGI support, Python 3.8, and other build dependencies
RUN apt-get update && apt-get install -y apache2 cgi-mapserver python3.8 python3.8-dev python3-pip build-essential git wget && rm -rf /var/lib/apt/lists/*

# Set Python 3.8 as the default Python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# Upgrade pip to the latest version for Python 3.8
RUN python -m pip install --upgrade pip

# Install CMake 3.20
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.sh && \
    chmod +x cmake-3.20.0-linux-x86_64.sh && \
    ./cmake-3.20.0-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.20.0-linux-x86_64.sh

# Clone MapServer repository and build MapScript from source
RUN git clone https://github.com/MapServer/MapServer.git /mapserver-src && \
    cd /mapserver-src && \
    mkdir build && cd build && \
    /usr/local/bin/cmake .. -DWITH_PYTHON=ON -DPYTHON_EXECUTABLE=/usr/bin/python3.8 && \
    make && \
    make install

# Install FastAPI and Uvicorn
RUN python -m pip install fastapi uvicorn

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