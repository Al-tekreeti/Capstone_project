# Dockerfile
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY index.html .

CMD ["nginx", "-g", "daemon off;"]
