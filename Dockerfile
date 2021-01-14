FROM nginx:latest
COPY ssl.conf /etc/nginx/conf.d/
COPY ca.crt ca.key auth_ca1.crt auth_ca2.crt /etc/nginx/
RUN mkdir -p usr/share/nginx/html/one usr/share/nginx/html/two

COPY one.html /usr/share/nginx/html/one/
COPY two.html /usr/share/nginx/html/two/
RUN nginx -V
