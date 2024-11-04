ARG NGINX_VERSION=1.27.2
ARG BITNAMI_NGINX_REVISION=r1
# ARG BITNAMI_NGINX_TAG=${NGINX_VERSION}-debian-10-${BITNAMI_NGINX_REVISION}
ARG BITNAMI_NGINX_TAG=${NGINX_VERSION}

FROM bitnami/nginx:${BITNAMI_NGINX_TAG} AS builder
USER root
# Redeclare NGINX_VERSION so it can be used as a parameter inside this build stage
ARG NGINX_VERSION
# Install required packages and build dependencies
RUN apt-get update -y
RUN install_packages dirmngr \
         gpg \
         gpg-agent \
         mercurial \
         curl \
         build-essential \
         libpcre3-dev \
         zlib1g-dev \
         libperl-dev \
         libssl-dev \
         libxslt-dev \
         libxml2-dev

# Add trusted NGINX PGP key for tarball integrity verification
# RUN gpg --keyserver pgp.mit.edu --recv-key D6786CE303D9A902
# RUN gpg --fingerprint D6786CE303D9A902
RUN curl -O https://nginx.org/keys/nginx_signing.key
RUN curl -O https://nginx.org/keys/arut.key
RUN curl -O https://nginx.org/keys/pluknet.key
RUN curl -O https://nginx.org/keys/sb.key
RUN curl -O https://nginx.org/keys/thresh.key
RUN gpg --import nginx_signing.key
RUN gpg --import arut.key
RUN gpg --import pluknet.key
RUN gpg --import sb.key
RUN gpg --import thresh.key

# Download NGINX, verify integrity and extract
WORKDIR /tmp 
RUN curl -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN curl -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc 
RUN gpg --verify nginx-${NGINX_VERSION}.tar.gz.asc nginx-${NGINX_VERSION}.tar.gz 
RUN tar xzf nginx-${NGINX_VERSION}.tar.gz 
RUN export CFLAGS="-m64 -march=native -mtune=native -Ofast -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections"
RUN export LDFLAGS="-m64 -Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"
RUN hg clone http://hg.nginx.org/njs -r 0.8.4
# Compile NGINX with desired module
WORKDIR /tmp/nginx-${NGINX_VERSION}
RUN rm -rf /opt/bitnami/nginx 
RUN ./configure \
        --prefix=/opt/bitnami/nginx \
        --with-compat \
        --add-dynamic-module=../njs/nginx
RUN make 
RUN make install

FROM bitnami/nginx:${BITNAMI_NGINX_TAG}
USER root
# Install ngx_http_perl_module system package dependencies
RUN install_packages libperl-dev
# Install ngx_http_perl_module files
# COPY --from=builder /usr/local/lib/x86_64-linux-gnu/perl /usr/local/lib/x86_64-linux-gnu/perl
# COPY --from=builder /opt/bitnami/nginx/modules/ngx_http_perl_module.so /opt/bitnami/nginx/modules/ngx_http_perl_module.so
COPY --from=builder /opt/bitnami/nginx/modules/ngx_http_js_module.so /opt/bitnami/nginx/modules/ngx_http_js_module.so
# Enable module
# RUN echo "load_module modules/ngx_http_perl_module.so; load_module modules/ngx_http_js_module.so;" | cat - /opt/bitnami/nginx/conf/nginx.conf > /tmp/nginx.conf && \
RUN echo "load_module modules/ngx_http_js_module.so;" | cat - /opt/bitnami/nginx/conf/nginx.conf > /tmp/nginx.conf && \
    cp /tmp/nginx.conf /opt/bitnami/nginx/conf/nginx.conf
# Set the container to be run as a non-root user by default
USER 1001