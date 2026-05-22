FROM nginx:alpine

# Remove the default boilerplate configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom routing rules
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]