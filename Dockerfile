FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install both Apache and nginx
RUN apt-get update && apt-get install -y \
    nginx \
    apache2 \
    apache2-utils \
    fcgiwrap \
    spawn-fcgi \
    curl \
    coreutils \
    grep \
    sed \
    gawk \
    && rm -rf /var/lib/apt/lists/*

# Set up WIT directory structure
RUN mkdir -p /opt/wit/bin \
    && mkdir -p /opt/wit/conf \
    && mkdir -p /opt/wit/data/Discussion/Topics \
    && mkdir -p /opt/wit/data/Discussion/Admin/People \
    && mkdir -p /opt/wit/icons \
    && mkdir -p /opt/wit/html \
    && mkdir -p /run/nginx

# Copy WIT files
COPY wit-modern/bin/ /opt/wit/bin/
COPY wit-modern/conf/ /opt/wit/conf/
COPY wit-modern/icons/ /opt/wit/icons/
COPY wit-modern/html/ /opt/wit/html/

# Make scripts executable
RUN chmod +x /opt/wit/bin/*

# Set ownership for data directory
RUN chown -R www-data:www-data /opt/wit/data

# Apache setup
RUN a2enmod cgi auth_basic authn_file && \
    a2dissite 000-default.conf && \
    ln -sf /opt/wit/conf/wit-apache.conf /etc/apache2/sites-available/wit.conf && \
    ln -sf /etc/apache2/sites-available/wit.conf /etc/apache2/sites-enabled/wit.conf

# Nginx setup
RUN rm -f /etc/nginx/sites-enabled/default && \
    ln -sf /opt/wit/conf/nginx.conf /etc/nginx/nginx.conf && \
    ln -sf /opt/wit/conf/wit-nginx.conf /etc/nginx/sites-enabled/wit.conf

ENV WIT_ROOT=/opt/wit
ENV WIT_SERVER=nginx

VOLUME /opt/wit/data

EXPOSE 80

COPY wit-modern/bin/entrypoint.sh /opt/wit/bin/
RUN chmod +x /opt/wit/bin/entrypoint.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["/opt/wit/bin/entrypoint.sh"]
