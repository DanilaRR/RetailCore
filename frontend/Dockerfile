# Dockerfile for Frontend
FROM node:20-alpine

WORKDIR /app

# Build arguments - default to localhost for browser access
ARG VITE_API_BASE_URL=http://localhost:8081

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the app - use localhost by default (accessible from browser)
RUN VITE_API_BASE_URL=${VITE_API_BASE_URL} npm run build

# Serve using a simple server
RUN npm install -g serve

EXPOSE 5173

CMD ["serve", "-s", "dist", "-l", "5173"]
