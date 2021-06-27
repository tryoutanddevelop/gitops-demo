FROM nginx:1.14.2

COPY src /usr/share/nginx/html
COPY conf /etc/nginx/conf.d