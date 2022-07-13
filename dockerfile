FROM nginx:alpine
COPY appsource /usr/share/nginx/html
EXPOSE 80