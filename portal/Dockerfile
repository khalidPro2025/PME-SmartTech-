FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY login.html /usr/share/nginx/html/login.html
COPY css/style.css /usr/share/nginx/html/css/style.css
COPY js/api.js /usr/share/nginx/html/js/api.js
COPY js/dashboard.js /usr/share/nginx/html/js/dashboard.js
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

