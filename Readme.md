# Nginx - Authen request

We use Kekcloak for Oauth Server

### Run container without js module
```shell
docker run -p 8080:8080 --name nginx -d bitnami/nginx:1.20.0
```

### Run container with js module
```shell
docker build -t bitnami/nginx:1.20.0-custom .
docker run -p 8080:8080 --name nginx-custom -d bitnami/nginx:1.20.0-custom
```

### Copy conf file to docker
```shell
docker cp server-custom.conf nginx-custom:/opt/bitnami/nginx/conf/server_blocks
docker cp oauth2.js nginx-custom:/opt/bitnami/nginx/conf/server_blocks
docker restart nginx-custom && docker logs -f nginx-custom
```

# Reference Document
-   [https://hub.docker.com/r/bitnami/nginx](https://hub.docker.com/r/bitnami/nginx)
-   [https://www.nginx.com/blog/validating-oauth-2-0-access-tokens-nginx](https://www.nginx.com/blog/validating-oauth-2-0-access-tokens-nginx/)