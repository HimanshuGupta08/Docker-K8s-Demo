# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy app files
COPY . .

# Expose the port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
