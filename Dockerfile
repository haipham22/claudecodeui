# Use Node.js 18-alpine for a smaller image size
FROM node:22-alpine AS base

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm ci

# Copy source code
COPY . .

# Build the client
RUN npm run build

# Production stage
FROM node:18-alpine

# Install runtime dependencies
RUN apk add --no-cache python3 make g++

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy built application
COPY --from=base /app/dist ./dist
COPY --from=base /app/server ./server

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Start the application
CMD ["node", "server/index.js"]