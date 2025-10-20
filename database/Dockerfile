FROM mongo:7.0

# Copy initialization scripts
COPY init/ /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod +x /docker-entrypoint-initdb.d/*.js

# Expose MongoDB port
EXPOSE 27017

# Use the default MongoDB entrypoint
CMD ["mongod"]
